# cc.ps1 - Universal Claude Code Launcher (Windows)
# Cross-platform launcher with proxy support and API fallback
#
# Usage: cc [args]   (extra args pass through to claude)

param(
  [switch]$p,
  [Parameter(ValueFromRemainingArguments=$true)] [string[]]$ClaudeArgs
)

# ============================================================================
# Configuration (loaded from config.json or environment variables)
# ============================================================================

$ConfigDir = Join-Path ([Environment]::GetFolderPath("ApplicationData")) "claude-launcher"
$ConfigFile = Join-Path $ConfigDir "config.json"
$StateFile = Join-Path $ConfigDir "subscription-state.json"
$StateTtl = 300  # seconds

# Ensure config directory exists
if (-not (Test-Path -LiteralPath $ConfigDir)) {
  New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

# Load or create default config
function Load-Config {
  if (Test-Path -LiteralPath $ConfigFile) {
    try {
      return Get-Content -LiteralPath $ConfigFile -Raw | ConvertFrom-Json
    } catch {
      Write-Warning "Failed to load config, using defaults"
    }
  }

  # Default configuration
  return [pscustomobject]@{
    apiProvider = "anthropic"
    customApiBase = ""
    apiKey = ""
    proxy = @{
      enabled = $false
      url = "http://127.0.0.1:7890"
    }
    defaults = @{
      model = "claude-opus-5-5"
      effort = "medium"
    }
    subscriptionCache = @{
      enabled = $true
      ttl = 300
    }
  }
}

$Config = Load-Config

# Override from environment variables
if ($env:ANTHROPIC_API_KEY) { $Config.apiKey = $env:ANTHROPIC_API_KEY }
if ($env:ANTHROPIC_BASE_URL) { $Config.customApiBase = $env:ANTHROPIC_BASE_URL }
if ($env:HTTPS_PROXY) {
  $Config.proxy.enabled = $true
  $Config.proxy.url = $env:HTTPS_PROXY
}

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Status([string]$Message) {
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Success([string]$Message) {
  Write-Host "==> $Message" -ForegroundColor Green
}

function Write-Warn([string]$Message) {
  Write-Host "==> $Message" -ForegroundColor Yellow
}

function Get-ArgValue([string[]]$ArgsList, [string]$Name, [string]$Default) {
  if ($null -eq $ArgsList) { return $Default }
  for ($i = 0; $i -lt $ArgsList.Count; $i++) {
    if ($null -eq $ArgsList[$i]) { continue }
    $Arg = [string]$ArgsList[$i]
    if ($Arg -eq $Name -and ($i + 1) -lt $ArgsList.Count -and $null -ne $ArgsList[$i + 1]) {
      return [string]$ArgsList[$i + 1]
    }
    if ($Arg.StartsWith("$Name=")) {
      return [string]$Arg.Substring($Name.Length + 1)
    }
  }
  return $Default
}

function Read-SubscriptionState {
  if (-not $Config.subscriptionCache.enabled) { return $null }
  if (-not (Test-Path -LiteralPath $StateFile)) { return $null }
  try {
    $state = Get-Content -LiteralPath $StateFile -Raw | ConvertFrom-Json
    $age = ([DateTimeOffset]::UtcNow - [DateTimeOffset]::Parse($state.checkedAtUtc)).TotalSeconds
    if ($age -ge 0 -and $age -lt $StateTtl) { return $state }
  } catch { }
  return $null
}

function Write-SubscriptionState([string]$Status) {
  if (-not $Config.subscriptionCache.enabled) { return }
  try {
    [pscustomobject]@{
      status = $Status
      checkedAtUtc = [DateTimeOffset]::UtcNow.ToString("o")
    } | ConvertTo-Json | Set-Content -LiteralPath $StateFile -Encoding utf8 -NoNewline
  } catch { }
}

function Test-SubscriptionAvailable {
  $probeOut = Join-Path ([IO.Path]::GetTempPath()) ("cc-probe-" + [Guid]::NewGuid().ToString("N") + ".log")
  $probeModel = Get-ArgValue $RunArgs "--model" $Config.defaults.model
  $probeEffort = Get-ArgValue $RunArgs "--effort" $Config.defaults.effort

  try {
    & claude --safe-mode --print --no-session-persistence `
      --model $probeModel --effort $probeEffort `
      "Reply with exactly OK" *> $probeOut
    return ($LASTEXITCODE -eq 0)
  } finally {
    Remove-Item -LiteralPath $probeOut -Force -ErrorAction SilentlyContinue
  }
}

function Test-ProxyConnection([string]$ProxyUrl) {
  try {
    $uri = [Uri]$ProxyUrl
    $connection = Get-NetTCPConnection -State Listen -LocalPort $uri.Port -ErrorAction SilentlyContinue
    return ($null -ne $connection)
  } catch {
    return $false
  }
}

function Get-ExitIp([string]$ProxyUrl) {
  try {
    $result = & curl.exe -s -x $ProxyUrl --max-time 5 https://checkip.amazonaws.com 2>$null
    return $result.Trim()
  } catch {
    return ""
  }
}

# ============================================================================
# Main Logic
# ============================================================================

Write-Status "Claude Code Launcher"

# Build run args
$RunArgs = @()
if ($p) { $RunArgs += "-p" }
if ($null -ne $ClaudeArgs -and $ClaudeArgs.Count -gt 0) {
  $RunArgs += @($ClaudeArgs)
}

# Check if this is a management command
$ManagementCommand = $false
if ($null -ne $ClaudeArgs -and $ClaudeArgs.Count -gt 0) {
  $ManagementCommands = @("attach", "stop", "login", "logout", "auth", "update", "mcp", "plugin", "doctor", "help", "version")
  if ($ManagementCommands -contains $ClaudeArgs[0]) {
    $ManagementCommand = $true
  }
}

# Add default model and effort (unless management command)
if (-not $ManagementCommand) {
  if (-not ($RunArgs -contains "--model") -and -not ($RunArgs -contains "-m")) {
    $RunArgs += @("--model", $Config.defaults.model)
  }
  if (-not ($RunArgs -contains "--effort")) {
    $RunArgs += @("--effort", $Config.defaults.effort)
  }
}

$PrintMode = ($RunArgs -contains "-p" -or $RunArgs -contains "--print")
$UseFallback = $false

# Configure proxy if enabled
if ($Config.proxy.enabled) {
  Write-Status "Proxy: $($Config.proxy.url)"

  if (Test-ProxyConnection $Config.proxy.url) {
    $env:HTTPS_PROXY = $Config.proxy.url
    $env:HTTP_PROXY = $Config.proxy.url
    $env:NO_PROXY = "localhost,127.0.0.1,::1"

    $exitIp = Get-ExitIp $Config.proxy.url
    if ($exitIp) {
      Write-Success "Exit IP = $exitIp"
    } else {
      Write-Warn "Proxy configured but exit IP check failed"
    }
  } else {
    Write-Warn "Proxy not reachable: $($Config.proxy.url)"
  }
}

# Check subscription availability (if using official API)
if ($Config.apiProvider -eq "anthropic" -and -not $PrintMode) {
  $state = Read-SubscriptionState
  if ($state -and $state.status -eq "unavailable") {
    $UseFallback = $true
  } elseif (-not $state) {
    Write-Status "Checking subscription availability..."
    if (Test-SubscriptionAvailable) {
      Write-SubscriptionState "available"
    } else {
      Write-SubscriptionState "unavailable"
      $UseFallback = $true
    }
  }
}

# Launch Claude Code
Write-Status "Launching Claude Code..."

if ($UseFallback -or $Config.apiProvider -ne "anthropic") {
  # Use custom API gateway
  if ([string]::IsNullOrWhiteSpace($Config.apiKey)) {
    Write-Error "API key not configured. Please run: cc --configure"
    exit 1
  }

  if ([string]::IsNullOrWhiteSpace($Config.customApiBase)) {
    Write-Error "Custom API base URL not configured. Please run: cc --configure"
    exit 1
  }

  Write-Warn "Using custom API gateway: $($Config.customApiBase)"
  $env:ANTHROPIC_BASE_URL = $Config.customApiBase
  $env:ANTHROPIC_AUTH_TOKEN = $Config.apiKey
  $env:ANTHROPIC_API_KEY = $null
}

& claude @RunArgs
$ExitCode = $LASTEXITCODE

exit $ExitCode
