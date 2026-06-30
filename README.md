# App Explorer

App Explorer 是一个面向 TrollStore 环境的极简应用浏览工具。

当前目标不是做复杂的系统助手，而是先把一个基础能力做好：快速查看设备中安装的应用，并获取应用图标、名称、Bundle ID、版本和路径信息。

## 当前功能

- 浏览已安装应用
- 搜索应用名称和 Bundle ID
- 查看应用详情
- 复制 Bundle ID、Bundle Path、Data Path
- 导出应用图标为 PNG
- 默认中文界面
- 支持中文 / English 切换
- 关于页内展示开源地址

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

## 开源地址

https://github.com/hhse/App-Explorer.git

## 状态

项目还在完善中，当前版本优先保证核心浏览、搜索和图标导出流程可用。
