# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · **简体中文** · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

本项目将网页版 2.5D 角色播放器 [LivLiv Player](https://github.com/livliv-dev/player)（TypeScript/WebGL2）移植为 **iOS、macOS 和 visionOS 原生 App**。角色用 **Metal** 绘制，VRM 头像用本项目在 **RealityKit** 上编写的 glTF/VRM 加载器绘制。

## 系统要求

- iOS 18、macOS 15 或 visionOS 2 及更高版本（Xcode 16 及更高版本，Swift 6 工具链）
- 没有外部依赖。App 的逻辑位于本地 Swift 包（`Packages/LivLivKit`）中。

## 构建

1. 在 Xcode 中打开 `livlivIOSPlayer.xcodeproj`。
2. 在 Signing & Capabilities 中选择你自己的 Team，如有需要再修改 Bundle ID。
3. 选择 iPhone 或 iPad（真机或模拟器）、My Mac 或 Apple Vision Pro 作为运行目标，然后按 Run（⌘R）。

`LivLivCore` 即使在 Debug 下也用 `-O` 构建，因为骨架每帧要移动数万个顶点（以 k01 为例，`-Onone` 每帧约 17 ms，`-O` 约 2 ms）。

## 功能

- **角色**：内置 21 个角色
- **导入**：选择你放进 App 的 Documents 文件夹中的文件夹或文件，App 会先检查能否打开，再进行加载。无法打开时，会在可选择、可拷贝的文本视图提醒框中显示原因。
- Documents 文件夹位置：在 iPhone、iPad 和 Vision Pro 上为“文件”App › 我的 iPhone › livlivIOSPlayer；在 Mac 上为导入中的“在 Finder 中打开 Documents 文件夹”。“从其他位置选择…”可以打开其他位置的文件夹或文件。
- 表情、动作和打盹。角色会跟随指针，轻点时摆动部件会弹动，还可以双指捏合缩放。
- 通过麦克风或音频文件进行**口型同步**，在配备原深感摄像头的 iPhone 或 iPad 上进行**面部追踪**
- **设置**：动作、分辨率、面部追踪，以及开源许可 ›“许可与商标”

## 支持的格式

- LivLiv 模型文件夹（`model.json` + `textures/`）、`.livliv` / `.zip`
- `.vrm` / `.glb`（VRM 0.x / 1.0），包括用 Blender 版 VRM Add-on 导出的文件
- PNGTuber 文件夹：`closed.png`、`open.png`（可选：`blink.png`、`blink-open.png`、`name.txt`）

无法播放的文件（没有网格的 VRM、Draco / Meshopt / KTX2 压缩、过大的图像）会被拒绝并说明原因。

## 本地化

- App 的文本有 50 种语言，存放在 String Catalog（`livlivIOSPlayer/Localizable.xcstrings`、`InfoPlist.xcstrings`）中。开发语言为英语，各地区的英语变体也使用英语。
- “许可与商标”文档在韩语设备上显示韩语，在其他设备上显示英语。角色名称、署名和许可证原文不作翻译。
- 本 README 也提供相同的语言版本（见顶部链接）。译文尚未经过母语人士审校，欢迎提出修改建议。

## 项目结构

```
livlivIOSPlayer.xcodeproj      one multiplatform app target (iphoneos, macosx, xros)
livlivIOSPlayer/               the app
  App/                         entry point, AppModel
  Views/                       screens, settings, licenses, import, failure alert
  Resources/Legal/             Licenses and Trademarks (ko, en), Apache-2.0, NOTICE
  Localizable.xcstrings        UI text, 50 languages
  InfoPlist.xcstrings          camera and microphone usage text
Config/                        Info.plist, macOS sandbox entitlements
Packages/LivLivKit/            Swift package
  Sources/LivLivCore/          pure Swift: formats, rig, motion, lip sync, glTF/VRM
  Sources/LivLivKit/           Metal, RealityKit, audio, ARKit, SwiftUI views
  Sources/LivLivSamples/       21 bundled characters (own license)
  Tests/LivLivCoreTests/       core tests (swift test)
docs/readme/                   translations of this README
```

## 原始代码 → 移植

| Original (TypeScript) | Port (Swift) |
|---|---|
| `runtime/puppet.ts` | `LivLivCore/Puppet.swift`, `LivLivKit/MetalRenderer.swift` |
| `runtime/format.ts`, `zip.ts` | `ModelFormat.swift`, `Keyforms.swift`, `Zip.swift` |
| `runtime/idle.ts`, `follow.ts`, `talk.ts`, `actions.ts`, `base.ts` | `LivelyIdle.swift`, `Motion.swift`, `Composer.swift` |
| `runtime/voice.ts`, `vowel.ts`, `speech.ts` | `Voice.swift`, `LivLivKit/LipSync.swift` |
| `runtime/tracking.ts` (MediaPipe) | `Composer.swift` (FaceMapper), `LivLivKit/FaceTracking.swift` (ARKit) |
| `png.ts` | `LivLivKit/CharacterStage.swift` |
| `vrm.ts` (three.js, three-vrm) | `VRM/GLTF.swift`, `VRMModel.swift`, `VRMRig.swift`, `LivLivKit/VRMStageView.swift` |
| `mark.ts`, `runtime/brand.ts` | `LivLivKit/Watermark.swift` |

## 测试

```sh
cd Packages/LivLivKit
swift test
```

在 Linux 上验证的内容：读取 21 个内置角色并各播放 240 帧（表情、动作、嘴型、虹膜模板），关键形态，链条弹动，ZIP，口型同步分析，读取和拒绝 VRM 0.x / 1.0，蒙皮、变形和弹簧骨骼，以及 Blender 版 VRM Add-on 写入的内容（只列出名称而未使用的压缩、`KHR_texture_transform`、采样器）。

## 已知差异与限制

- **MToon** 用 RealityKit 的 Unlit 材质近似（基础色、纹理、Alpha 模式、双面）。没有边缘光和阴影分界。
- **VRM** 的蒙皮和变形在 CPU 上计算，每帧写入 LowLevelMesh。顶点非常多的模型建议使用 Release 构建。
- **面部追踪**使用 ARKit（原深感），因此在 Mac 和 Vision Pro 上不可用。由于没有嘴唇特征点，张嘴程度只由 `jawOpen` 决定。
- **visionOS**：VRM 在窗口中高约 0.36 m。

## 许可证

- 代码：与 LivLiv Player 相同的 Apache License 2.0（`livlivIOSPlayer/Resources/Legal/`）
- 内置角色：**不适用** Apache 许可证。仅限非商业用途，并须署名。Kujira 和 Kujira Q 为 CC BY-NC-SA 4.0，Pen 不授予任何权利。分发前请阅读 App 中的“许可与商标”。
- LivLiv 名称和标志不在任何许可证范围内。
