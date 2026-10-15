# ScrollFlow

Lightweight Auto-Scroll for macOS
一款极简轻量的 macOS 自动滚动菜单栏小工具

A lightweight native macOS menu bar app for auto-scrolling web pages, novels, long documents and feeds.
Built with Swift + SwiftUI/AppKit, running locally only with no networking or analytics.

## 功能特性 | Features

- 仅驻留菜单栏，不显示 Dock 图标，无主窗口
- 设置页支持开机自启开关
- 可录制全局快捷键，一键开启 / 暂停自动滚动
- 支持调节滚动速度（1-12 级）
- 支持三种滚动方向：向下 / 向上 / 交替
- 支持平滑滚动模式
- 基于系统辅助功能权限发送全局滚动事件
- 纯本地运行，无网络请求、无数据上传
- 用户输入时自动暂停，2 秒后恢复
- 电池供电时自动暂停
- 实时监听辅助功能权限变化

## 项目结构 | Structure

- `/ScrollFlow.xcodeproj`：Xcode 工程与共享 Scheme
- `/ScrollFlow/App`：应用入口与状态编排
- `/ScrollFlow/Models`：设置模型与快捷键模型
- `/ScrollFlow/Services`：滚动、快捷键、开机自启、权限、设置持久化
- `/ScrollFlow/Features`：菜单栏 UI 与设置页 UI
- `/ScrollFlow/Utilities`：格式化、本地化等通用工具
- `/ScrollFlowTests`：单元测试（46 个测试用例）

## 本地运行 | Run Locally

1. 在 macOS 上使用 Xcode 16+ 打开仓库根目录下的 `ScrollFlow.xcodeproj`
2. 选择共享 Scheme：`ScrollFlow`
3. 首次运行后，在系统设置中授予"辅助功能"权限
4. 在设置页中配置开机自启、快捷键和滚动速度

## 开源协议 | License

MIT License — 自由使用、修改、分发。
