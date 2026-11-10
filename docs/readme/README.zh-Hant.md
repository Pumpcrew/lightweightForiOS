# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · **繁體中文** · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

本專案將網頁版 2.5D 角色播放器 [LivLiv Player](https://github.com/livliv-dev/player)（TypeScript/WebGL2）移植為 **iOS、macOS 和 visionOS 原生 App**。角色以 **Metal** 繪製，VRM 頭像以本專案在 **RealityKit** 上撰寫的 glTF/VRM 載入器繪製。

## 系統需求

- iOS 18、macOS 15 或 visionOS 2 以上版本（Xcode 16 以上版本，Swift 6 工具鏈）
- 沒有外部相依項目。App 的邏輯位於本機 Swift 套件（`Packages/LivLivKit`）中。

## 建置

1. 在 Xcode 中打開 `livlivIOSPlayer.xcodeproj`。
2. 在 Signing & Capabilities 中選擇你自己的 Team，必要時再更改 Bundle ID。
3. 選擇 iPhone 或 iPad（實機或模擬器）、My Mac 或 Apple Vision Pro 作為執行目標，然後按下 Run（⌘R）。

`LivLivCore` 即使在 Debug 中也以 `-O` 建置，因為骨架每一格要移動數萬個頂點（以 k01 為例，`-Onone` 每格約 17 ms，`-O` 約 2 ms）。

## 功能

- **角色**：內建 21 個角色
- **匯入**：選擇你放進 App 的 Documents 檔案夾中的檔案夾或檔案，App 會先檢查能否打開，再進行載入。無法打開時，會在可選取、可拷貝的文字視圖提示框中顯示原因。
- Documents 檔案夾位置：在 iPhone、iPad 和 Vision Pro 上為「檔案」App › 我的 iPhone › livlivIOSPlayer；在 Mac 上為匯入中的「在 Finder 中打開 Documents 檔案夾」。「從其他位置選擇⋯」可以打開其他位置的檔案夾或檔案。
- 表情、動作和打瞌睡。角色會跟隨指標，點一下時擺動部件會彈動，也可以雙指開合縮放。
- 透過麥克風或音訊檔進行**口型同步**，在配備原深感相機的 iPhone 或 iPad 上進行**臉部追蹤**
- **設定**：動作、解析度、臉部追蹤，以及開放原始碼授權 ›「授權與商標」

## 支援的格式

- LivLiv 模型檔案夾（`model.json` + `textures/`）、`.livliv` / `.zip`
- `.vrm` / `.glb`（VRM 0.x / 1.0），包括以 Blender 版 VRM Add-on 輸出的檔案
- PNGTuber 檔案夾：`closed.png`、`open.png`（選用：`blink.png`、`blink-open.png`、`name.txt`）

無法播放的檔案（沒有網格的 VRM、Draco / Meshopt / KTX2 壓縮、過大的影像）會被拒絕並說明原因。

## 在地化

- App 的文字有 50 種語言，存放在 String Catalog（`livlivIOSPlayer/Localizable.xcstrings`、`InfoPlist.xcstrings`）中。開發語言為英文，各地區的英文變體也使用英文。
- 「授權與商標」文件在韓文裝置上顯示韓文，在其他裝置上顯示英文。角色名稱、署名和授權條款原文不作翻譯。
- 本 README 也提供相同的語言版本（見頂端連結）。譯文尚未經母語人士校閱，歡迎提出修正建議。

## 專案結構

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

## 原始程式碼 → 移植

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

## 測試

```sh
cd Packages/LivLivKit
swift test
```

在 Linux 上驗證的內容：讀取 21 個內建角色並各播放 240 格（表情、動作、嘴型、虹膜模板），關鍵形態，鏈條彈動，ZIP，口型同步分析，讀取和拒絕 VRM 0.x / 1.0，蒙皮、變形和彈簧骨骼，以及 Blender 版 VRM Add-on 寫入的內容（只列出名稱而未使用的壓縮、`KHR_texture_transform`、取樣器）。

## 已知差異與限制

- **MToon** 以 RealityKit 的 Unlit 材質近似（基本色、紋理、Alpha 模式、雙面）。沒有邊緣光和陰影分界。
- **VRM** 的蒙皮和變形在 CPU 上計算，每格寫入 LowLevelMesh。頂點非常多的模型建議使用 Release 建置。
- **臉部追蹤**使用 ARKit（原深感），因此在 Mac 和 Vision Pro 上無法使用。由於沒有嘴唇特徵點，張嘴程度只由 `jawOpen` 決定。
- **visionOS**：VRM 在視窗中高約 0.36 m。

## 授權

- 程式碼：與 LivLiv Player 相同的 Apache License 2.0（`livlivIOSPlayer/Resources/Legal/`）
- 內建角色：**不適用** Apache 授權。僅限非商業用途，並須署名。Kujira 和 Kujira Q 為 CC BY-NC-SA 4.0，Pen 不授予任何權利。散布前請閱讀 App 中的「授權與商標」。
- LivLiv 名稱和標誌不在任何授權範圍內。
