# 打包测试完整指南

## 📋 打包前检查清单

### 1. 环境准备

```powershell
# 检查 Node.js 版本（需要 18+）
node --version

# 检查 npm 版本
npm --version

# 检查 Claude Code CLI
claude --version
```

### 2. 项目完整性检查

```bash
cd D:\claude-launcher

# 检查必需文件
ls package.json          # ✓
ls README.md             # ✓
ls scripts/cc.ps1        # ✓
ls scripts/cc.sh         # ✓
ls electron/main.js      # ✓
ls electron/index.html   # ✓
```

---

## 🔧 第一步：安装依赖

```bash
cd D:\claude-launcher

# 清理旧依赖（如果有）
rm -rf node_modules package-lock.json

# 安装所有依赖
npm install

# 验证安装
npm list --depth=0
```

**预期输出**：
```
claude-code-launcher@1.0.0
├── electron@28.0.0
└── electron-store@8.1.0
```

---

## 🎨 第二步：生成图标

### 方式 A：使用脚本（需要 ImageMagick）

```powershell
# 安装 ImageMagick
choco install imagemagick

# 生成图标
cd resources\icons
powershell -ExecutionPolicy Bypass -File generate-icons.ps1
```

### 方式 B：在线生成（快速）

1. 打开：https://cloudconvert.com/svg-to-png
2. 上传：`resources/icons/icon.svg`
3. 设置尺寸：512
4. 下载并重命名为 `icon.png`
5. 放到：`resources/icons/icon.png`

**Windows .ico**：
1. 打开：https://convertio.co/png-ico/
2. 上传：`icon.png`
3. 下载 `icon.ico`
4. 放到：`resources/icons/icon.ico`

### 验证图标

```bash
ls resources/icons/icon.png   # 必需
ls resources/icons/icon.ico   # Windows 必需
ls resources/icons/icon.icns  # macOS 必需（可选）
```

---

## 🚀 第三步：开发模式测试

在打包前，先测试开发模式：

```bash
cd D:\claude-launcher

# 启动开发模式
npm run dev
```

**测试内容**：
- ✅ 应用能正常启动
- ✅ 图标显示正确
- ✅ UI 界面正常
- ✅ 设置页面可以保存配置
- ✅ "Launch Claude Code" 按钮能触发启动

**常见问题**：
```
Error: Cannot find module 'electron-store'
解决：npm install electron-store
```

---

## 📦 第四步：打包 Windows 应用

### 4.1 首次打包测试

```bash
cd D:\claude-launcher

# 构建（不创建安装包，快速测试）
npm run build

# 或直接打包为安装程序
npm run build:win
```

**打包过程**：
```
1. [10%] Checking dependencies...
2. [30%] Building Electron app...
3. [50%] Packaging for Windows...
4. [70%] Creating installer...
5. [90%] Signing (skipped if no cert)...
6. [100%] Done!
```

**预计时间**：3-5 分钟（首次打包）

### 4.2 输出位置

打包完成后，文件在：
```
D:\claude-launcher\dist\
├── win-unpacked/              # 未打包的应用（可直接运行）
│   └── Claude Launcher.exe    # 测试用
└── Claude-Launcher-Setup-1.0.0.exe  # 安装程序（分发用）
```

### 4.3 测试未打包版本

```bash
# 直接运行（无需安装）
cd dist/win-unpacked
"Claude Launcher.exe"
```

**测试内容**：
- ✅ 应用启动正常
- ✅ 图标显示（任务栏、标题栏）
- ✅ 配置保存到 `%APPDATA%\claude-launcher\`
- ✅ 能正常启动 Claude Code
- ✅ 代理设置生效

### 4.4 测试安装程序

```bash
# 运行安装程序
dist/Claude-Launcher-Setup-1.0.0.exe
```

**安装测试**：
- ✅ 安装向导正常
- ✅ 可选择安装路径
- ✅ 创建桌面快捷方式
- ✅ 创建开始菜单项
- ✅ 安装后能正常启动

**卸载测试**：
- 控制面板 → 程序和功能 → 卸载
- 或：开始菜单 → Claude Launcher → Uninstall

---

## 🐛 常见打包问题

### 问题 1：`electron-builder` 未找到

```bash
npm install --save-dev electron-builder
```

### 问题 2：打包卡在 "downloading winCodeSign"

```bash
# 跳过代码签名（测试用）
npm run build:win -- --publish never
```

### 问题 3：图标未显示

```bash
# 检查图标路径
ls resources/icons/icon.ico

# 确认 package.json 中的路径
grep "icon" package.json
```

应该看到：
```json
"win": {
  "icon": "resources/icons/icon.ico"
}
```

### 问题 4：打包体积过大

正常体积：~150-200 MB（包含 Electron runtime）

如果超过 300MB：
```bash
# 检查是否误包含了 node_modules
grep -A5 "files" package.json
```

### 问题 5：启动后立即崩溃

```bash
# 查看日志
%APPDATA%\claude-launcher\logs\

# 或以调试模式运行
set DEBUG=*
"Claude Launcher.exe"
```

---

## ✅ 完整测试流程

### 快速测试（10 分钟）

```bash
# 1. 安装依赖
cd D:\claude-launcher
npm install

# 2. 生成图标（在线）
# 访问 https://cloudconvert.com/svg-to-png
# 上传 icon.svg，下载 icon.png 和 icon.ico

# 3. 开发模式测试
npm run dev
# 验证：能启动、UI 正常、功能可用

# 4. 打包测试
npm run build:win
# 等待 3-5 分钟

# 5. 运行测试
cd dist/win-unpacked
"Claude Launcher.exe"
# 验证：能启动、配置保存、可以启动 Claude Code
```

### 完整测试（30 分钟）

```bash
# 1-4 同上

# 5. 安装程序测试
dist/Claude-Launcher-Setup-1.0.0.exe
# 安装到默认路径

# 6. 功能测试
# - 配置 API provider
# - 启用/禁用代理
# - 测试连接
# - 启动 Claude Code
# - 修改默认 model/effort

# 7. 配置导入导出
# - 导出配置
# - 卸载应用
# - 重新安装
# - 导入配置
# - 验证配置恢复

# 8. 多用户测试（可选）
# - 切换 Windows 账户
# - 验证配置隔离
```

---

## 📊 打包性能基准

**首次打包**：
- 下载 Electron：~100MB
- 打包时间：3-5 分钟
- 输出大小：~150MB

**后续打包**：
- 打包时间：1-2 分钟（缓存生效）

**优化建议**：
```json
// package.json - 添加到 build 配置
"compression": "maximum",
"asar": true,
"asarUnpack": ["scripts/**/*"]
```

---

## 🎯 下一步计划

### 打包完成后

1. **Windows 测试通过** → 继续 macOS 打包
2. **功能测试通过** → 准备发布说明
3. **性能测试通过** → 创建 GitHub Release

### macOS 打包（需要 Mac 环境）

```bash
# 在 macOS 上
npm run build:mac

# 输出
dist/Claude-Launcher-1.0.0.dmg
```

### Linux 打包

```bash
npm run build:linux

# 输出
dist/Claude-Launcher-1.0.0.AppImage
dist/claude-launcher_1.0.0_amd64.deb
```

---

## 📝 打包后的清单

### Windows 发布包
- [ ] `Claude-Launcher-Setup-1.0.0.exe` (安装程序)
- [ ] `latest.yml` (自动更新配置)
- [ ] `CHANGELOG.md` (更新日志)

### 测试记录
- [ ] 安装测试通过
- [ ] 卸载测试通过
- [ ] 功能测试通过
- [ ] 配置导入导出通过
- [ ] 多用户隔离通过

### 文档
- [ ] README.md 更新
- [ ] 截图添加到 docs/
- [ ] 使用教程完成

---

## 🚀 现在开始

**立即执行**：

```bash
cd D:\claude-launcher

# 1. 安装依赖
npm install

# 2. 测试开发模式
npm run dev
```

如果开发模式正常，继续：

```bash
# 3. 打包
npm run build:win
```

**遇到问题？** 参考上面的"常见打包问题"部分，或告诉我具体的错误信息！
