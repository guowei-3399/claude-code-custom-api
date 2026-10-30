# One-Click Setup Script for Claude Code Launcher (Windows)
# Run with: powershell -ExecutionPolicy Bypass -File setup.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Claude Code Launcher - Quick Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check dependencies
Write-Host "Checking dependencies..." -ForegroundColor Yellow

# Node.js
try {
  $nodeVersion = & node --version 2>$null
  Write-Host "✓ Node.js $nodeVersion" -ForegroundColor Green
} catch {
  Write-Host "❌ Node.js not found. Please install Node.js 18+ from https://nodejs.org" -ForegroundColor Red
  exit 1
}

# npm
try {
  $npmVersion = & npm --version 2>$null
  Write-Host "✓ npm $npmVersion" -ForegroundColor Green
} catch {
  Write-Host "❌ npm not found" -ForegroundColor Red
  exit 1
}

# Claude Code CLI
try {
  & claude --version 2>$null | Out-Null
  Write-Host "✓ Claude Code CLI installed" -ForegroundColor Green
} catch {
  Write-Host "⚠️  Claude Code CLI not found. Please install from https://claude.ai/code" -ForegroundColor Yellow
  Write-Host "   The launcher will work, but you need Claude Code to actually launch sessions." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
npm install

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Configure your settings:"
Write-Host "   - API key (if using custom gateway)"
Write-Host "   - Proxy (if needed)"
Write-Host ""
Write-Host "2. Run the application:"
Write-Host "   npm run dev         (development mode)"
Write-Host "   npm run build       (build for production)"
Write-Host "   npm run package     (create installer)"
Write-Host ""
Write-Host "3. For CLI-only usage:"
Write-Host "   powershell -ExecutionPolicy Bypass -File scripts\cc.ps1 `"your question`""
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Happy coding with Claude! 🚀" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
