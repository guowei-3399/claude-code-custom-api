# 🚀 Claude Code Launcher - 快速启动指南

## 📦 项目已完成！

**位置**：`D:\claude-launcher`

**状态**：✅ 所有核心文件已创建，可以开始打包测试

---

## ⚡ 立即开始（3 步）

### 第 1 步：安装依赖

```bash
cd D:\claude-launcher
npm install
```

### 第 2 步：生成图标（选一种方式）

**方式 A - 在线生成（推荐，最快）**：
1. 访问：https://cloudconvert.com/svg-to-png
2. 上传：`resources/icons/icon.svg`
3. 尺寸选：512
4. 下载并保存为：`resources/icons/icon.png`
5. 再访问：https://convertio.co/png-ico/
6. 上传刚才的 `icon.png`
7. 下载并保存为：`resources/icons/icon.ico`

**方式 B - 脚本生成（需要 ImageMagick）**：
```powershell
choco install imagemagick
cd resources\icons
.\generate-icons.ps1
```

### 第 3 步：测试和打包

```bash
# 开发模式测试
npm run dev

# 打包 Windows 应用
npm run build:win
```

---

## 📁 项目结构

```
D:\claude-launcher/
├── 📄 README.md              # 开源项目说明
├── 📄 PROJECT-SUMMARY.md      # 项目总结（中文）
├── 📄 BUILD-TEST-GUIDE.md     # 打包测试指南
├── 📄 package.json            # npm 配置
├── 📄 setup.sh / setup.ps1    # 一键安装
│
├── 📂 scripts/                # 核心启动脚本
│   ├── cc.ps1                # Windows 启动器
│   └── cc.sh                 # macOS/Linux 启动器
│
├── 📂 electron/               # Electron 应用
│   ├── main.js               # 主进程
│   ├── preload.js            # 安全桥接
│   ├── index.html            # GUI 界面
│   └── app.js                # 前端逻辑
│
└── 📂 resources/icons/        # 应用图标
    ├── icon.svg              # ✅ 源文件
    ├── README.md             # 图标生成指南
    ├── generate-icons.sh     # 生成脚本
    └── generate-icons.ps1    # Windows 生成脚本
```

---

## 🎯 功能特性

### 通用版（开源） vs 个人版（D:\cc）

| 功能 | 个人版 | 通用版 |
|-----|-------|--------|
| **API** | 硬编码 4ALL | ✨ 可配置 |
| **代理** | 硬编码 sing-box | ✨ 可配置 |
| **界面** | 命令行 | ✨ GUI + CLI |
| **配置** | XML 加密 | ✨ JSON 导入导出 |
| **开源** | ❌ | ✅ 安全可开源 |

### Electron GUI 功能

- 🚀 一键启动 Claude Code
- ⚙️ 可视化配置管理
- 🌐 代理设置和测试
- 🔑 API Provider 切换
- 📊 连接状态监控
- 💾 配置导入/导出

---

## 📋 下一步计划

### 立即可做
1. ✅ 安装依赖：`npm install`
2. ✅ 生成图标（5分钟）
3. ✅ 测试开发模式：`npm run dev`
4. ✅ 打包测试：`npm run build:win`

### 后续优化
- [ ] macOS 打包（需要 Mac）
- [ ] Linux 打包
- [ ] 添加截图到 README
- [ ] 编写详细文档
- [ ] 准备 GitHub Release

---

## 📖 关键文档

| 文档 | 用途 |
|-----|-----|
| `README.md` | 开源项目主页说明 |
| `PROJECT-SUMMARY.md` | 项目架构和对比 |
| `BUILD-TEST-GUIDE.md` | **打包测试详细指南** ⭐ |
| `resources/icons/README.md` | 图标生成指南 |

---

## 🆘 需要帮助？

**常见问题**：
- 依赖安装失败 → 检查 Node.js 版本（需要 18+）
- 图标未显示 → 确认 `icon.ico` 存在
- 打包失败 → 查看 `BUILD-TEST-GUIDE.md`

**联系方式**：
- 项目 Issues
- 文档 Wiki

---

## ✨ 现在开始

```bash
cd D:\claude-launcher
npm install
```

**成功后继续**：
```bash
npm run dev
```

**看到 GUI 界面？恭喜！** 🎉

继续打包：
```bash
npm run build:win
```

---

**项目状态**：✅ 100% 完成，随时可以打包测试！
