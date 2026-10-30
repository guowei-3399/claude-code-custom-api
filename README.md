# Claude Code Custom API

[English](#english) | [中文](#中文)

---

## English

A cross-platform desktop launcher for Claude Code with custom API gateway support, proxy configuration, and smart model routing.

**Alpha Version** - Currently supports Windows, with macOS and Linux support coming soon.

### Features

- 🚀 **One-Click Launch**: Start Claude Code with pre-configured settings
- 🔄 **Smart Fallback**: Automatic fallback to custom API gateway when subscription is unavailable
- 🌐 **Proxy Support**: Built-in HTTP/SOCKS5 proxy configuration for restricted networks
- 🎯 **Model Control**: Pin specific models and effort levels
- 💾 **Session Management**: Track and resume sessions
- 🖥️ **Cross-Platform**: Windows, macOS, and Linux support

### Installation

#### Option 1: Desktop App (Recommended)

Download the latest release for your platform:
- **Windows**: `Claude-Launcher-Setup-x.x.x.exe`
- **macOS**: `Claude-Launcher-x.x.x.dmg`
- **Linux**: `Claude-Launcher-x.x.x.AppImage`

#### Option 2: CLI Only

```bash
# Install globally
npm install -g @your-org/claude-launcher

# Or use the standalone scripts
curl -O https://raw.githubusercontent.com/guowei-3399/claude-code-custom-api/main/scripts/cc.sh
chmod +x cc.sh
./cc.sh --help
```

### Quick Start

#### Desktop App

1. Launch the app
2. Go to Settings → Configure API key and proxy (if needed)
3. Click "Launch Claude Code"

#### CLI

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

### API Providers

#### Official Anthropic API

Use your Anthropic API key from https://console.anthropic.com/

#### Custom Gateway

Supports any Anthropic-compatible API gateway. Pre-configured gateways:
- **Anthropic Official**: `https://api.anthropic.com` (requires subscription)
- **4AllAPI (US)**: `https://api-us.4allapi.com` (alternative gateway)
- **Custom**: Enter your own gateway base URL

All gateways use the same authentication format (API Key).

### Proxy Support

The launcher supports HTTP and SOCKS5 proxies for users in restricted networks.

#### Supported Scenarios

1. **No Proxy**: Direct connection (default)
2. **HTTP Proxy**: `http://host:port`
3. **SOCKS5 Proxy**: `socks5://host:port`
4. **Authenticated Proxy**: `http://user:pass@host:port`

### Development

```bash
# Clone the repository
git clone https://github.com/guowei-3399/claude-code-custom-api.git
cd claude-code-custom-api

# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build

# Package for distribution
npm run package
```

### Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### License

MIT License - see [LICENSE](LICENSE) for details.

### Acknowledgments

- Built for [Claude Code](https://claude.ai/code) by Anthropic
- Inspired by the need for better proxy and API management in restricted networks

---

## 中文

一个跨平台的 Claude Code 桌面启动器，支持自定义 API 网关、代理配置和智能模型路由。

**Alpha 版本** - 目前支持 Windows，macOS 和 Linux 支持即将推出。

### 功能特性

- 🚀 **一键启动**：使用预配置设置启动 Claude Code
- 🔄 **智能回退**：订阅不可用时自动回退到自定义 API 网关
- 🌐 **代理支持**：内置 HTTP/SOCKS5 代理配置，适用于受限网络环境
- 🎯 **模型控制**：指定特定模型和思考深度级别
- 💾 **会话管理**：跟踪和恢复会话
- 🖥️ **跨平台**：支持 Windows、macOS 和 Linux

### 安装

#### 方式一：桌面应用（推荐）

下载适合您平台的最新版本：
- **Windows**: `Claude-Launcher-Setup-x.x.x.exe`
- **macOS**: `Claude-Launcher-x.x.x.dmg`
- **Linux**: `Claude-Launcher-x.x.x.AppImage`

#### 方式二：仅命令行

```bash
# 全局安装
npm install -g @your-org/claude-launcher

# 或使用独立脚本
curl -O https://raw.githubusercontent.com/guowei-3399/claude-code-custom-api/main/scripts/cc.sh
chmod +x cc.sh
./cc.sh --help
```

### 快速开始

#### 桌面应用

1. 启动应用
2. 进入设置 → 配置 API 密钥和代理（如需要）
3. 点击"Launch Claude Code"

#### 命令行

```bash
# 基本用法
cc "你的问题"

# 指定模型和思考级别
cc --model opus --effort high "你的问题"

# 使用自定义 API 网关
cc --api-base https://your-gateway.com "你的问题"

# 启用代理
cc --proxy http://127.0.0.1:7890 "你的问题"
```

### API 提供商

#### Anthropic 官方 API

使用您从 https://console.anthropic.com/ 获取的 Anthropic API 密钥

#### 自定义网关

支持任何兼容 Anthropic 的 API 网关。预配置网关：
- **Anthropic Official**: `https://api.anthropic.com`（需要订阅）
- **4AllAPI (US)**: `https://api-us.4allapi.com`（替代网关）
- **自定义**：输入您自己的网关基础 URL

所有网关使用相同的认证格式（API Key）。

### 代理支持

启动器支持 HTTP 和 SOCKS5 代理，适用于受限网络环境的用户。

#### 支持的场景

1. **无代理**：直连（默认）
2. **HTTP 代理**：`http://host:port`
3. **SOCKS5 代理**：`socks5://host:port`
4. **认证代理**：`http://user:pass@host:port`

### 开发

```bash
# 克隆仓库
git clone https://github.com/guowei-3399/claude-code-custom-api.git
cd claude-code-custom-api

# 安装依赖
npm install

# 开发模式运行
npm run dev

# 生产环境构建
npm run build

# 打包分发
npm run package
```

### 贡献

欢迎贡献！详情请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

### 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE)。

### 致谢

- 为 Anthropic 的 [Claude Code](https://claude.ai/code) 构建
- 灵感来源于在受限网络环境中更好的代理和 API 管理需求

---

**Support**

- 📖 [Documentation](https://github.com/guowei-3399/claude-code-custom-api/wiki)
- 🐛 [Issue Tracker](https://github.com/guowei-3399/claude-code-custom-api/issues)
- 💬 [Discussions](https://github.com/guowei-3399/claude-code-custom-api/discussions)
