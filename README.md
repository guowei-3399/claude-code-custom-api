# Claude Code Launcher

A cross-platform desktop launcher for Claude Code with proxy support, API fallback, and smart model routing.

## Features

- 🚀 **One-Click Launch**: Start Claude Code with pre-configured settings
- 🔄 **Smart Fallback**: Automatic fallback to custom API gateway when subscription is unavailable
- 🌐 **Proxy Support**: Built-in HTTP/SOCKS5 proxy configuration for restricted networks
- 🎯 **Model Control**: Pin specific models and effort levels
- 💾 **Session Management**: Track and resume sessions
- 🖥️ **Cross-Platform**: Windows, macOS, and Linux support

## Installation

### Option 1: Desktop App (Recommended)

Download the latest release for your platform:
- **Windows**: `Claude-Launcher-Setup-x.x.x.exe`
- **macOS**: `Claude-Launcher-x.x.x.dmg`
- **Linux**: `Claude-Launcher-x.x.x.AppImage`

### Option 2: CLI Only

```bash
# Install globally
npm install -g @your-org/claude-launcher

# Or use the standalone scripts
curl -O https://raw.githubusercontent.com/your-org/claude-launcher/main/scripts/cc.sh
chmod +x cc.sh
./cc.sh --help
```

## Quick Start

### Desktop App

1. Launch the app
2. Go to Settings → Configure API key and proxy (if needed)
3. Click "Launch Claude Code"

### CLI

```bash
# Basic usage
cc "Your question"

# Specify model and effort
cc --model opus --effort high "Your question"

# Use custom API gateway
cc --api-base https://your-gateway.com "Your question"

# Enable proxy
cc --proxy http://127.0.0.1:7890 "Your question"
```

## Configuration

The app stores configuration in:
- **Windows**: `%APPDATA%\claude-launcher\config.json`
- **macOS**: `~/Library/Application Support/claude-launcher/config.json`
- **Linux**: `~/.config/claude-launcher/config.json`

### Example config.json

```json
{
  "apiProvider": "anthropic",
  "customApiBase": "",
  "apiKey": "",
  "proxy": {
    "enabled": false,
    "url": "http://127.0.0.1:7890"
  },
  "defaults": {
    "model": "claude-opus-5-5",
    "effort": "medium"
  },
  "subscriptionCache": {
    "enabled": true,
    "ttl": 300
  }
}
```

## Development

### Prerequisites

- Node.js 18+
- npm or yarn

### Setup

```bash
# Clone the repository
git clone https://github.com/your-org/claude-launcher.git
cd claude-launcher

# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build

# Package for distribution
npm run package
```

### Project Structure

```
claude-launcher/
├── scripts/          # Core launcher scripts (cc.ps1, cc.sh)
├── electron/         # Electron main process
├── src/
│   ├── renderer/    # UI components (React)
│   └── core/        # Core logic (config, launcher)
├── resources/       # Icons, assets
└── build/          # Build configuration
```

## API Providers

### Official Anthropic API

Use your Anthropic API key from https://console.anthropic.com/

### Custom Gateway

Any OpenAI-compatible or Anthropic-compatible API gateway:
- Base URL: Your gateway's base URL (e.g., `https://api.example.com`)
- API Key: Your gateway's authentication token

## Proxy Support

The launcher supports HTTP and SOCKS5 proxies for users in restricted networks.

### Supported Scenarios

1. **No Proxy**: Direct connection (default)
2. **HTTP Proxy**: `http://host:port`
3. **SOCKS5 Proxy**: `socks5://host:port`
4. **Authenticated Proxy**: `http://user:pass@host:port`

### Testing Proxy

```bash
# Test proxy connection
cc --proxy http://127.0.0.1:7890 --test-connection
```

## Roadmap

- [x] Windows support
- [x] macOS support
- [x] Linux support
- [x] Proxy configuration
- [x] API fallback
- [ ] Multi-account support
- [ ] Usage analytics
- [ ] Custom prompt templates
- [ ] Session history browser

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- Built for [Claude Code](https://claude.ai/code) by Anthropic
- Inspired by the need for better proxy and API management in restricted networks

## Support

- 📖 [Documentation](https://github.com/your-org/claude-launcher/wiki)
- 🐛 [Issue Tracker](https://github.com/your-org/claude-launcher/issues)
- 💬 [Discussions](https://github.com/your-org/claude-launcher/discussions)
