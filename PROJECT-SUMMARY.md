# Claude Code Launcher - Project Summary

## 📁 项目结构

```
D:\claude-launcher/
├── README.md                 # 项目说明（英文，开源）
├── package.json              # Node.js 依赖配置
├── setup.sh                  # 一键安装脚本（macOS/Linux）
├── setup.ps1                 # 一键安装脚本（Windows）
├── scripts/                  # 核心启动脚本
│   ├── cc.ps1               # Windows 启动器（通用版）
│   └── cc.sh                # macOS/Linux 启动器（通用版）
├── electron/                 # Electron 桌面应用
│   ├── main.js              # 主进程
│   ├── preload.js           # 预加载脚本
│   ├── index.html           # UI 界面
│   └── app.js               # 前端逻辑
├── resources/                # 资源文件
│   └── icons/               # 应用图标（待添加）
└── build/                    # 构建配置

对比：你的个人版
D:\cc/
├── cc.ps1                    # 个人版（硬编码 4ALL、sing-box）
├── cc.sh                     # 个人版
├── config-jy.json           # 简云 sing-box 配置
└── .claude/
    └── AGENTS-strict.md     # API 模式强制 Opus 配置
```

## ✅ 已完成的工作

### 1. 通用版核心脚本
- ✅ `scripts/cc.ps1` - Windows 通用版启动器
- ✅ `scripts/cc.sh` - macOS/Linux 通用版启动器
- ✅ 配置文件：`config.json`（统一格式，支持导入导出）
- ✅ 功能对等个人版，但所有配置可定制

### 2. Electron 桌面应用
- ✅ `electron/main.js` - 主进程（IPC 通信、进程管理）
- ✅ `electron/preload.js` - 安全的渲染进程桥接
- ✅ `electron/index.html` - 精美的 GUI 界面
- ✅ `electron/app.js` - 前端交互逻辑

### 3. 一键部署
- ✅ `setup.sh` - Linux/macOS 一键安装
- ✅ `setup.ps1` - Windows 一键安装
- ✅ 自动检测依赖（Node.js、npm、Claude CLI）

### 4. 打包配置
- ✅ `package.json` - electron-builder 配置
- ✅ 支持打包：Windows (NSIS)、macOS (DMG)、Linux (AppImage/deb)

## 🎯 核心功能

### 通用版 vs 个人版对比

| 功能 | 个人版（D:\cc） | 通用版（开源） |
|-----|---------------|--------------|
| **API Provider** | 硬编码 4ALL | 可配置（官方/自定义） |
| **代理** | 硬编码 sing-box 7890 | 可配置（HTTP/SOCKS5/无） |
| **配置存储** | cc-fallback-key.xml | config.json（可导入导出） |
| **环境变量** | BLM_AGENT 等业务变量 | 标准 ANTHROPIC_* |
| **UI** | 命令行 | 命令行 + 桌面 GUI |
| **默认 effort** | xhigh | medium（更经济） |
| **订阅缓存** | 5 分钟 | 可配置开关 |
| **目标用户** | 你的团队 | 全球开发者 |

### 桌面应用功能

1. **快速启动**
   - 输入问题直接启动
   - 选择模型和 effort
   - 快捷操作（New Chat、Print Mode、Attach Session）

2. **配置管理**
   - API Provider 选择（官方/自定义网关）
   - 代理配置（HTTP/SOCKS5）
   - 默认模型和 effort 设置
   - 导入/导出配置

3. **连接测试**
   - 测试代理连接
   - 测试 API 可用性
   - 显示 Claude CLI 版本

## 🚀 使用方法

### 一键安装

**Windows:**
```powershell
cd D:\claude-launcher
powershell -ExecutionPolicy Bypass -File setup.ps1
```

**macOS/Linux:**
```bash
cd /d/claude-launcher
chmod +x setup.sh
./setup.sh
```

### 开发模式

```bash
npm run dev
```

### 打包分发

```bash
# Windows 安装包
npm run build:win

# macOS DMG
npm run build:mac

# Linux AppImage
npm run build:linux

# 全平台
npm run package
```

### CLI 使用（无需 Electron）

**Windows:**
```powershell
# 基本使用
.\scripts\cc.ps1 "你的问题"

# 指定模型和 effort
.\scripts\cc.ps1 --model opus --effort high "你的问题"
```

**macOS/Linux:**
```bash
# 基本使用
./scripts/cc.sh "你的问题"

# 指定模型和 effort
./scripts/cc.sh --model opus --effort high "你的问题"
```

## 📋 待完成事项

### 必需（发布前）
- [ ] 添加应用图标（`resources/icons/icon.ico|icns|png`）
- [ ] 测试 Windows 打包
- [ ] 测试 macOS 打包
- [ ] 测试 Linux 打包
- [ ] 编写 CONTRIBUTING.md
- [ ] 添加 LICENSE 文件（MIT）

### 可选（后续版本）
- [ ] 多账号支持
- [ ] 使用统计
- [ ] 自定义 prompt 模板
- [ ] 会话历史浏览器
- [ ] 自动更新检查
- [ ] 系统托盘图标
- [ ] 全局快捷键

## 🔐 安全注意事项

### 个人版
- API key 存储在加密的 XML（Windows DPAPI）
- 配置文件包含敏感信息（sing-box、4ALL key）
- **不要提交到 Git！**

### 通用版（开源）
- API key 存储在 electron-store（加密）
- 配置文件存储在用户目录
- 不包含任何硬编码凭证
- **可以安全开源！**

## 📦 发布清单

开源前检查：
- [ ] 移除所有硬编码的 API keys
- [ ] 移除个人/公司特定配置
- [ ] 确认 README 完整
- [ ] 添加示例配置文件
- [ ] 测试全平台安装
- [ ] 准备发布说明

## 🌐 开源仓库建议

**仓库名**: `claude-code-launcher`  
**描述**: Cross-platform desktop launcher for Claude Code with proxy support and API management  
**主题**: `claude`, `electron`, `launcher`, `proxy`, `ai`, `anthropic`  
**许可证**: MIT

## 📞 支持

- 文档：项目 Wiki
- 问题：GitHub Issues
- 讨论：GitHub Discussions

---

**当前状态**: ✅ 核心功能完成，可以开始测试和打包！
