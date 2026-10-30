# Icon Generation Script for Windows
# Requires ImageMagick: choco install imagemagick

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SvgFile = Join-Path $ScriptDir "icon.svg"
$OutputDir = $ScriptDir

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Icon Generation for Claude Launcher" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if SVG exists
if (-not (Test-Path $SvgFile)) {
  Write-Error "icon.svg not found at $SvgFile"
  exit 1
}

# Check ImageMagick
$hasConvert = Get-Command convert -ErrorAction SilentlyContinue
if (-not $hasConvert) {
  Write-Warning "ImageMagick not found. Install with: choco install imagemagick"
  Write-Host "Or use online converter: https://cloudconvert.com/svg-to-png"
  exit 1
}

Write-Host ""
Write-Host "Generating PNG files..." -ForegroundColor Yellow

# Generate PNGs
$sizes = @(16, 32, 48, 64, 128, 256, 512, 1024)
foreach ($size in $sizes) {
  $output = Join-Path $OutputDir "icon-$size.png"
  Write-Host "  ${size}x${size}..." -NoNewline
  & magick convert -background none -density 600 -resize ${size}x${size} "$SvgFile" "$output"
  Write-Host " ✓" -ForegroundColor Green
}

# Copy main icon
Copy-Item (Join-Path $OutputDir "icon-512.png") (Join-Path $OutputDir "icon.png") -Force

Write-Host ""
Write-Host "Generating Windows .ico file..." -ForegroundColor Yellow

# Create .ico with multiple resolutions
& magick convert `
  (Join-Path $OutputDir "icon-16.png") `
  (Join-Path $OutputDir "icon-32.png") `
  (Join-Path $OutputDir "icon-48.png") `
  (Join-Path $OutputDir "icon-64.png") `
  (Join-Path $OutputDir "icon-128.png") `
  (Join-Path $OutputDir "icon-256.png") `
  (Join-Path $OutputDir "icon.ico")

Write-Host "✓ icon.ico created" -ForegroundColor Green

Write-Host ""
Write-Host "Generating macOS .icns file..." -ForegroundColor Yellow
Write-Host "Note: .icns generation requires macOS or png2icns tool" -ForegroundColor Yellow
Write-Host "Use online converter: https://cloudconvert.com/png-to-icns" -ForegroundColor Yellow
Write-Host "Upload icon-1024.png to generate icon.icns" -ForegroundColor Yellow

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Icon Generation Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Generated files:"
Write-Host "  - icon.svg         (source file)"
Write-Host "  - icon.png         (512x512, for Linux)"
Write-Host "  - icon.ico         (multi-res, for Windows)"
Write-Host "  - icon-*.png       (individual sizes)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Generate icon.icns for macOS (see link above)"
Write-Host "  2. Run: npm run build:win"
Write-Host ""
