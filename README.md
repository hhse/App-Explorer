# App Explorer

App Explorer 是一个面向 TrollStore 环境的极简应用浏览工具。

当前目标不是做复杂的系统助手，而是先把一个基础能力做好：快速查看设备中安装的应用，并获取应用图标、名称、Bundle ID、版本和路径信息。

## 当前功能

- 浏览已安装应用
- 搜索应用名称和 Bundle ID
- 查看应用详情：Bundle ID、Version、Build、Minimum iOS、Executable、Bundle Path、Data Path
- 复制 Bundle ID、Bundle Path、Data Path
- 导出应用图标为 PNG
- 支持原始尺寸、1024、180、120 图标规格导出
- 导出应用 Info.plist
- 默认中文界面
- 支持中文 / English 切换
- 关于页内提供 Telegram、GitHub、公众号入口

## 环境说明

- iOS 15.0+
- 面向 TrollStore / 私有 API 环境
- 不面向 App Store 上架

## 技术说明

项目使用 SwiftUI 构建界面，通过私有 API 获取应用列表和图标：

- `LSApplicationWorkspace`
- `LSApplicationProxy`
- `UIImage` 私有图标接口
- `SpringBoardServices`

私有 API 兼容性会随 iOS 版本变化，当前版本仍处于早期开发阶段。

## 链接

- Telegram 频道：[TheBallnow](https://t.me/TheBallnow)
- GitHub：[hhse](https://github.com/hhse)
- 公众号：[joia.cn](https://joia.cn/)
- 仓库：[hhse/App-Explorer](https://github.com/hhse/App-Explorer.git)

## 建议开发路线

### 第一阶段：完整的应用资源导出工具

- 补充更多应用信息：Team ID、URL Scheme、CFBundleURLTypes、LSApplicationQueriesSchemes
- 增加资源导出：LaunchImage、Assets、Entitlements
- 完善详情页高频复制：Bundle ID、Version、Bundle Path、Data Path
- 建立统一的导出中心

### 第二阶段：批量导出

- 批量导出全部 App 图标
- 支持按应用名或 Bundle ID 自动命名
- 支持按规格导出：原始尺寸、1024x1024、180x180、120x120
- 导出 App 元数据 JSON

### 第三阶段：开发者工具

- 查看 Info.plist
- 查看 URL Scheme
- 查看 LSApplicationQueriesSchemes
- 查看 CFBundleURLTypes

### 第四阶段：分析工具

- 查看 Executable
- Mach-O 基础信息
- Architecture
- Team ID
- Entitlements

## 状态

项目还在完善中，当前版本优先保证核心浏览、搜索和图标导出流程可用。
