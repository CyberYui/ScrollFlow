# ScrollFlow

Lightweight Auto-Scroll for macOS  
一款极简轻量的 macOS 自动滚动菜单栏小工具

## 简介 | About

ScrollFlow 专为 macOS 设计，主打轻量、纯净、后台静默运行。  
用于网页、小说、长文档、信息流自动滚动浏览，替代高价同类付费软件。

A lightweight native macOS menu bar app for auto-scrolling web pages, novels, long documents and feeds.
Built with Swift + SwiftUI/AppKit, running locally only with no networking or analytics.

## 当前骨架能力 | Current Skeleton

- 仅驻留菜单栏，不显示 Dock 图标，无主窗口
- 设置页支持开机自启开关
- 可录制全局快捷键，一键开启 / 暂停自动滚动
- 支持调节滚动速度
- 基于系统辅助功能权限发送全局滚动事件
- 纯本地运行，未接入任何网络请求或数据上传

## 项目结构 | Structure

- `/ScrollFlow.xcodeproj`：Xcode 工程与共享 Scheme
- `/ScrollFlow/App`：应用入口与状态编排
- `/ScrollFlow/Models`：设置模型与快捷键模型
- `/ScrollFlow/Services`：滚动、快捷键、开机自启、权限、设置持久化
- `/ScrollFlow/Features`：菜单栏 UI 与设置页 UI
- `/ScrollFlow/Utilities`：格式化等通用工具
- `/ScrollFlowTests`：基础单元测试

## 本地运行 | Run Locally

1. 在 macOS 上使用 Xcode 16+ 打开仓库根目录下的 `ScrollFlow.xcodeproj`
2. 选择共享 Scheme：`ScrollFlow`
3. 首次运行后，在系统设置中授予“辅助功能”权限
4. 在设置页中配置开机自启、快捷键和滚动速度

## 定价说明 | Pricing

- 本仓库仅为项目源码托管，仅供学习参考
- 正式编译版将上架 Mac App Store，一次性买断 ¥7
- 无订阅、无内购、无广告

## 开发状态 | Status

🚧 基础骨架已搭建，可继续增量迭代。  
暂不提供安装包，请在 macOS + Xcode 环境中自行构建。

## 开源协议 | License

MIT License
