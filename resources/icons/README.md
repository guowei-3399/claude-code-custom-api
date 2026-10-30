# Icon Generation Guide

## 自动生成（推荐）

### Windows
```powershell
cd D:\claude-launcher\resources\icons
powershell -ExecutionPolicy Bypass -File generate-icons.ps1
```

**依赖**：ImageMagick
```powershell
# 安装 ImageMagick
choco install imagemagick
```

### macOS/Linux
```bash
cd /d/claude-launcher/resources/icons
chmod +x generate-icons.sh
./generate-icons.sh
```

**依赖**：
```bash
# Ubuntu/Debian
sudo apt-get install imagemagick inkscape

# macOS
brew install imagemagick inkscape
```

---

## 在线生成（无需安装工具）

如果不想安装 ImageMagick，可以使用在线工具：

### 1. SVG → PNG
- 网站：https://cloudconvert.com/svg-to-png
- 上传：`icon.svg`
- 生成尺寸：16, 32, 48, 64, 128, 256, 512, 1024
- 保存为：`icon-{size}.png`

### 2. PNG → ICO (Windows)
- 网站：https://convertio.co/png-ico/
- 上传：`icon-256.png`
- 下载：`icon.ico`

### 3. PNG → ICNS (macOS)
- 网站：https://cloudconvert.com/png-to-icns
- 上传：`icon-1024.png`
- 下载：`icon.icns`

---

## 手动设计（Figma/Sketch）

如果你想自定义设计：

### 设计规范
- **尺寸**：512×512 px（导出为 SVG）
- **圆角**：100px（约 20%）
- **配色**：
  - 主色：#667eea → #764ba2（渐变）
  - 强调色：#fbbf24（闪电图标）
- **元素**：
  - 闪电 ⚡（代表速度）
  - 字母 "C"（代表 Claude）

### Figma 模板
1. 打开 Figma
2. 新建 512×512 画布
3. 参考 `icon.svg` 的设计
4. 导出为 SVG

### 在线设计工具
- **Figma**: https://figma.com (免费)
- **Canva**: https://canva.com (简单易用)
- **Photopea**: https://photopea.com (类似 Photoshop)

---

## 所需的最终文件

打包 Electron 应用需要以下文件：

```
resources/icons/
├── icon.svg          # 源文件（可编辑）
├── icon.png          # 512×512（Linux）
├── icon.ico          # 多分辨率（Windows）
└── icon.icns         # 多分辨率（macOS）
```

**只需这 4 个文件**，electron-builder 会自动识别！

---

## 验证图标

生成后，验证图标是否正确：

### Windows
```powershell
# 查看 .ico 信息
magick identify icon.ico
```

### macOS
```bash
# 查看 .icns 信息
sips -g all icon.icns
```

### 预览
- Windows: 右键 → 属性 → 查看缩略图
- macOS: 在 Finder 中按空格键预览
- Linux: 直接在文件管理器中查看

---

## 常见问题

### Q: ImageMagick 安装失败
**A**: 使用在线工具生成，然后手动下载到 `resources/icons/`

### Q: 生成的图标很模糊
**A**: 确保 SVG 源文件质量高，或者提高导出分辨率

### Q: macOS .icns 生成失败
**A**: 在 Windows 上只能生成 .ico，.icns 需要在 macOS 上生成或使用在线工具

### Q: 我不喜欢当前的设计
**A**: 
1. 修改 `icon.svg`（用文本编辑器或 Figma）
2. 或者用 Figma 重新设计
3. 重新运行生成脚本

---

## 快速测试

生成图标后，立即测试：

```bash
# 开发模式（会显示图标）
npm run dev

# 如果图标正确显示，继续打包
npm run build:win
```

---

## 推荐工具总结

| 工具 | 用途 | 平台 | 安装 |
|-----|-----|-----|-----|
| **ImageMagick** | PNG/ICO 转换 | All | `choco install imagemagick` |
| **Inkscape** | SVG 编辑/转换 | All | `choco install inkscape` |
| **Figma** | 图标设计 | Web | https://figma.com |
| **CloudConvert** | 在线转换 | Web | https://cloudconvert.com |

---

**当前状态**: ✅ icon.svg 已创建，运行生成脚本即可！
