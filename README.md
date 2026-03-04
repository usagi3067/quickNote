# QuickNote

> 一个极简的 macOS 菜单栏应用，用全局快捷键快速捕获终端命令、选中文字到每日 Markdown 笔记，不打断你的工作流。

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 为什么需要 QuickNote？

你是否遇到过这些场景：

- 💻 在终端敲了一串复杂命令，想记下来但懒得切换到笔记 App
- 📝 看到一段有用的文字，想保存但不想打断当前思路
- 🔍 事后想回顾"今天都干了什么"，却发现终端历史已经被刷掉
- ⚡ 需要一个**零摩擦**的记录工具，按个快捷键就搞定

**QuickNote 就是为此而生。**

---

## 核心功能

### 🎯 两种记录模式

| 模式 | 快捷键 | 用途 | 适用场景 |
|------|--------|------|----------|
| **监听模式** | `Cmd+D` 开启/关闭 | 捕获你打的每一个字符，按回车记录为一条 | 终端命令、快速笔记 |
| **选中追加** | `Cmd+Shift+D` | 选中任意文字后一键追加到笔记 | 浏览器、文档、聊天记录 |

### 📅 自动整理

- 每天一个文件：`note_2026_03_04.md`
- 自动加时间戳：`### 14:32`
- Markdown 格式，方便后续搜索和整理

### 🔒 隐私优先

- 所有数据存储在本地（默认 `~/Documents/QuickNotes/`）
- 无网络请求，无数据上传
- 可自定义存储目录

### 🎨 极简设计

- 菜单栏常驻，无 Dock 图标
- 监听时图标变红 `●`，闲置时为 `○`
- 不干扰你的工作流

---

## 快速开始

### 下载安装

1. 前往 [Releases](../../releases) 下载最新的 `QuickNote.zip`
2. 解压后拖动 `QuickNote.app` 到「应用程序」文件夹
3. **首次打开：** 右键点击 App → 选择「打开」（绕过 macOS 的安全检查）

**如果右键打开仍提示安全警告：**

在终端运行以下命令移除隔离属性：
```bash
cd /Applications  # 或你放置 App 的目录
xattr -cr QuickNote.app
```
然后就可以正常打开了。

### 授权权限

首次启动会提示授权两个权限（必须）：

1. **辅助功能（Accessibility）** — 用于读取选中文字
2. **输入监控（Input Monitoring）** — 用于全局键盘监听

路径：`系统设置 → 隐私与安全性 → 辅助功能 / 输入监控`

授权后重启 App 即可使用。

---

## 使用示例

### 场景一：记录终端命令

```bash
# 按 Cmd+D 开启监听（菜单栏图标变红）
git clone https://github.com/user/repo.git
cd repo
npm install
# 再按 Cmd+D 停止监听
```

**生成的笔记：**
```markdown
### 14:32
1. git clone https://github.com/user/repo.git
2. cd repo
3. npm install
```

### 场景二：保存网页文字

在浏览器选中一段话 → 按 `Cmd+Shift+D` → 自动追加到今日笔记：

```markdown
### 15:20 ✂️
> 这是从网页上选中的一段重要内容
```

---

## 常见问题

### Q: 中文输入法下监听模式记录的是拼音？

**A:** 是的，这是 macOS 键盘监听的底层限制。`CGEventTap` 捕获的是 IME 转换前的原始按键。

**解决方案：** 中文内容请用 `Cmd+Shift+D` 选中追加，监听模式更适合终端命令（纯 ASCII）。

### Q: 为什么选中文字只在终端有效？

**A:** 已修复。最新版本使用剪贴板模拟方案，支持所有 App（浏览器、VS Code、微信等）。

### Q: 如何修改笔记存储位置？

**A:** 点击菜单栏图标 → 设置 → 选择文件夹。

### Q: 可以自定义快捷键吗？

**A:** 当前版本暂不支持，快捷键固定为 `Cmd+D` 和 `Cmd+Shift+D`。

---

## 从源码构建

如果你想自己编译：

```bash
# 克隆仓库
git clone https://github.com/你的用户名/QuickNote.git
cd QuickNote

# 构建（需要 Xcode 或 Command Line Tools）
./build.sh

# 运行
open QuickNote.app
```

**系统要求：**
- macOS 14.0+
- Xcode 15+ 或 Command Line Tools

---

## 技术栈

- **语言：** Swift 5.9
- **框架：** AppKit, CoreGraphics
- **构建：** Swift Package Manager
- **权限：** CGEventTap (全局键盘监听), AXUIElement (辅助功能)

---

## 开源协议

MIT License - 自由使用、修改、分发。

---

## 贡献

欢迎提交 Issue 和 Pull Request！

如果这个工具对你有帮助，给个 ⭐ 吧 😊
