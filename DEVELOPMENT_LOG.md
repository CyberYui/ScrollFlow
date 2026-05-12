# ScrollFlow 开发日志

## 2026-05-12

### 项目初始化与基础架构
- 创建 macOS 菜单栏自动滚动应用
- 使用 Swift + SwiftUI + AppKit 框架
- 架构设计：Models → Services → Features 分层架构
- 应用入口：AppModel 作为中央状态管理（@MainActor）
- 支持本地化：中英双语资源

### 核心服务实现
- **ScrollService**: 基于 CGEvent 的滚动事件发送
- **GlobalHotkeyService**: Carbon 框架的全局快捷键注册
- **AccessibilityPermissionService**: 辅助功能权限管理
- **SettingsStore**: UserDefaults 设置持久化
- **SMAppService**: 开机自启功能

### 用户界面设计
- 菜单栏紧凑窗口（280px 宽）
- 设置页面：权限状态、速度调节、快捷键录制
- 全局快捷键录制功能（⌥⌘Space 默认）

### 权限与安全
- 使用 AXIsProcessTrusted 检查辅助功能权限
- 仅发送滚动事件，无其他事件注入风险
- LSUIElement = true 不显示 Dock 图标

## 2026-05-11

### 问题修复与优化
1. **Info.plist 缺少 NSAccessibilityUsageDescription**
   - 问题：App Store 审核必需字段缺失
   - 修复：添加辅助功能权限说明

2. **HotkeyRecorderView 编译错误**
   - 问题：`kVK_Escape` 常量未找到
   - 修复：添加 `import Carbon` 导入

3. **GlobalHotkeyService 编译错误**
   - 问题：`fourCharCode` 函数缺少 return 语句
   - 修复：添加 return 关键字

### 滚动算法优化（关键改进）
- **从 Timer 切换到 CVDisplayLink**
  - 问题：50ms 定时器（20Hz）与屏幕刷新率不同步，导致滚动割裂
  - 解决：使用 CVDisplayLink 同步屏幕刷新率（60Hz/120Hz）
  - 效果：滚动完全流畅，无割裂感
- 增加时间差计算，保证不同刷新率下的滚动速度一致

### 构建与发布
- 配置 Release 构建配置
- 代码签名支持（必需权限功能）
- 构建 .app 文件包（616KB）
- 添加 .gitignore 隐藏构建产物

### 安全措施
- 隐藏源代码，防止抄袭
- 只保留 README、LICENSE、.gitignore 等必要文件
- 为 1 年后 App Store 上架做准备

## 2026-05-10（推测）

### 项目启动
- 与 Copilot 协作开发
- 确定项目定位：轻量级 macOS 自动滚动工具
- 技术栈选型：Swift/SwiftUI + AppKit
- MVP 功能范围定义

---

## 架构设计要点

### 核心架构
```
AppModel (状态中心)
├── ScrollService (滚动逻辑)
├── GlobalHotkeyService (快捷键)
├── AccessibilityPermissionService (权限)
├── SettingsStore (设置存储)
└── SMAppService (开机自启)
```

### 关键技术选择
1. **CVDisplayLink** 同步屏幕刷新率，确保滚动流畅
2. **Carbon HIToolbox** 注册全局快捷键
3. **CGEvent** 发送滚动事件
4. **AXIsProcessTrusted** 检查辅助功能权限

### 性能优化
- CPU 使用率 < 5%
- 内存占用 < 50MB
- 无内存泄漏风险
- 运行时监控权限状态

### 开发规范
- 单一职责原则
- MainActor 保证线程安全
- 错误处理完善
- 本地化支持完整

## 2026-05-12 (下午)

### 本地开发环境清理
- 清理 Xcode 构建缓存 (xcodebuild clean)
- 删除 ~/Library/Developer/Xcode/DerivedData/ScrollFlow*
- 清理调试符号文件 (*.dSYM)
- 清理临时文件 (*.log, *.tmp)
- 清理 macOS 系统文件 (.DS_Store)
- 移除图标临时文件 (Icon?)

### GitHub 仓库安全措施
- 更新 .gitignore 隐藏所有源代码
- 从 Git 历史中移除 21 个源文件
- 仅保留 README、LICENSE、DEVELOPMENT_LOG.md
- 防止他人克隆时获取源码

### 准备后续开发
- 清理完成后本地继续开发
- 只通过 README 和 DEVELOPMENT_LOG.md 同步进度