#!/bin/bash
# One-Click Setup Script for Claude Code Launcher
# Supports Windows (Git Bash), macOS, and Linux

set -e

echo "=========================================="
echo "  Claude Code Launcher - Quick Setup"
echo "=========================================="
echo ""

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="mac"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  OS="windows"
fi

echo "Detected OS: $OS"
echo ""

# Check dependencies
echo "Checking dependencies..."

# Node.js
if ! command -v node &> /dev/null; then
  echo "❌ Node.js not found. Please install Node.js 18+ from https://nodejs.org"
  exit 1
fi
echo "✓ Node.js $(node --version)"

# npm
if ! command -v npm &> /dev/null; then
  echo "❌ npm not found"
  exit 1
fi
echo "✓ npm $(npm --version)"

# Claude Code CLI
if ! command -v claude &> /dev/null; then
  echo "⚠️  Claude Code CLI not found. Please install from https://claude.ai/code"
  echo "   The launcher will work, but you need Claude Code to actually launch sessions."
fi

echo ""
echo "Installing npm dependencies..."
npm install

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Configure your settings:"
echo "   - API key (if using custom gateway)"
echo "   - Proxy (if needed)"
echo ""
echo "2. Run the application:"
echo "   npm run dev         (development mode)"
echo "   npm run build       (build for production)"
echo "   npm run package     (create installer)"
echo ""
echo "3. For CLI-only usage:"
if [[ "$OS" == "windows" ]]; then
  echo "   powershell -ExecutionPolicy Bypass -File scripts/cc.ps1 \"your question\""
else
  echo "   chmod +x scripts/cc.sh"
  echo "   ./scripts/cc.sh \"your question\""
fi
echo ""
echo "=========================================="
echo "Happy coding with Claude! 🚀"
echo "=========================================="
