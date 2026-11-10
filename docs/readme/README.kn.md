# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · **ಕನ್ನಡ** · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

ಈ ಪ್ರಾಜೆಕ್ಟ್ ವೆಬ್‌ಗಾಗಿ ಇರುವ 2.5D ಪಾತ್ರ ಪ್ಲೇಯರ್ [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2) ಅನ್ನು **iOS, macOS ಮತ್ತು visionOS ಗಾಗಿ ನೇಟಿವ್ ಆ್ಯಪ್** ಆಗಿ ಪರಿವರ್ತಿಸುತ್ತದೆ. ಪಾತ್ರಗಳನ್ನು **Metal** ಮೂಲಕ, VRM ಅವತಾರಗಳನ್ನು ಈ ಪ್ರಾಜೆಕ್ಟ್‌ಗಾಗಿ **RealityKit** ಮೇಲೆ ಬರೆದ glTF/VRM ಲೋಡರ್ ಮೂಲಕ ಚಿತ್ರಿಸಲಾಗುತ್ತದೆ.

## ಅಗತ್ಯಗಳು

- iOS 18, macOS 15 ಅಥವಾ visionOS 2 ಅಥವಾ ನಂತರದ್ದು (Xcode 16 ಅಥವಾ ನಂತರದ್ದು, Swift 6 ಟೂಲ್‌ಚೈನ್)
- ಯಾವುದೇ ಬಾಹ್ಯ ಅವಲಂಬನೆ ಇಲ್ಲ. ಆ್ಯಪ್‌ನ ಲಾಜಿಕ್ ಸ್ಥಳೀಯ Swift ಪ್ಯಾಕೇಜ್‌ನಲ್ಲಿ (`Packages/LivLivKit`) ಇದೆ.

## ಬಿಲ್ಡ್

1. Xcode ನಲ್ಲಿ `livlivIOSPlayer.xcodeproj` ತೆರೆಯಿರಿ.
2. Signing & Capabilities ನಲ್ಲಿ ನಿಮ್ಮ Team ಆರಿಸಿ, ಅಗತ್ಯವಿದ್ದರೆ ಬಂಡಲ್ ಐಡೆಂಟಿಫೈಯರ್ ಬದಲಿಸಿ.
3. ರನ್ ಗಮ್ಯವಾಗಿ iPhone ಅಥವಾ iPad (ಸಾಧನ ಅಥವಾ ಸಿಮ್ಯುಲೇಟರ್), My Mac ಅಥವಾ Apple Vision Pro ಆರಿಸಿ, ನಂತರ Run (⌘R) ಒತ್ತಿ.

`LivLivCore` ಅನ್ನು Debug ನಲ್ಲೂ `-O` ಜೊತೆ ಬಿಲ್ಡ್ ಮಾಡಲಾಗುತ್ತದೆ, ಏಕೆಂದರೆ ರಿಗ್ ಪ್ರತಿ ಫ್ರೇಮ್‌ನಲ್ಲಿ ಹತ್ತಾರು ಸಾವಿರ ವರ್ಟೆಕ್ಸ್‌ಗಳನ್ನು ಚಲಿಸುತ್ತದೆ (k01: `-Onone` ನಲ್ಲಿ ಪ್ರತಿ ಫ್ರೇಮ್‌ಗೆ ಸುಮಾರು 17 ms, `-O` ನಲ್ಲಿ ಸುಮಾರು 2 ms).

## ವೈಶಿಷ್ಟ್ಯಗಳು

- **ಪಾತ್ರಗಳು**: 21 ಒಳಗೊಂಡಿರುವ ಪಾತ್ರಗಳು
- **ಆಮದು ಮಾಡಿ**: ಆ್ಯಪ್‌ನ Documents ಫೋಲ್ಡರ್‌ನಲ್ಲಿ ನೀವು ಇಟ್ಟ ಫೋಲ್ಡರ್ ಅಥವಾ ಫೈಲ್ ಆರಿಸಿ. ಆ್ಯಪ್ ಮೊದಲು ಅದನ್ನು ತೆರೆಯಬಹುದೇ ಎಂದು ಪರಿಶೀಲಿಸಿ ನಂತರ ಲೋಡ್ ಮಾಡುತ್ತದೆ. ಸಾಧ್ಯವಾಗದಿದ್ದರೆ, ಎಚ್ಚರಿಕೆಯು ಕಾರಣವನ್ನು ಆರಿಸಿ ನಕಲಿಸಬಹುದಾದ ಪಠ್ಯ ವೀಕ್ಷಣೆಯಲ್ಲಿ ತೋರಿಸುತ್ತದೆ.
- Documents ಫೋಲ್ಡರ್: iPhone, iPad ಮತ್ತು Vision Pro ನಲ್ಲಿ ಫೈಲ್ಸ್ › ನನ್ನ iPhone ನಲ್ಲಿ › livlivIOSPlayer; Mac ನಲ್ಲಿ ಆಮದು ಮಾಡಿ ನಲ್ಲಿರುವ “Finder ನಲ್ಲಿ Documents ಫೋಲ್ಡರ್ ತೆರೆಯಿರಿ”. “ಬೇರೆ ಸ್ಥಳದಿಂದ ಆರಿಸಿ…” ಬೇರೆ ಸ್ಥಳದ ಫೋಲ್ಡರ್ ಅಥವಾ ಫೈಲ್ ತೆರೆಯುತ್ತದೆ.
- ಭಾವಗಳು, ಕ್ರಿಯೆಗಳು ಮತ್ತು ತೂಕಡಿಕೆ. ಪಾತ್ರ ಪಾಯಿಂಟರ್ ಅನ್ನು ಹಿಂಬಾಲಿಸುತ್ತದೆ, ತೂಗುವ ಭಾಗಗಳು ತಟ್ಟಿದಾಗ ಪುಟಿಯುತ್ತವೆ, ಮತ್ತು ಪಿಂಚ್ ಮಾಡಿ ಝೂಮ್ ಮಾಡಬಹುದು.
- ಮೈಕ್ರೊಫೋನ್ ಅಥವಾ ಆಡಿಯೊ ಫೈಲ್‌ನಿಂದ **ಲಿಪ್ ಸಿಂಕ್**, ಮತ್ತು TrueDepth ಇರುವ iPhone ಅಥವಾ iPad ನಲ್ಲಿ **ಮುಖ ಟ್ರ್ಯಾಕಿಂಗ್**
- **ಸೆಟ್ಟಿಂಗ್‌ಗಳು**: ಚಲನೆ, ರೆಸಲ್ಯೂಶನ್, ಮುಖ ಟ್ರ್ಯಾಕಿಂಗ್, ಮತ್ತು ಓಪನ್ ಸೋರ್ಸ್ ಪರವಾನಗಿಗಳು › “ಪರವಾನಗಿಗಳು ಮತ್ತು ಟ್ರೇಡ್‌ಮಾರ್ಕ್‌ಗಳು”

## ಬೆಂಬಲಿತ ಸ್ವರೂಪಗಳು

- LivLiv ಮಾದರಿ ಫೋಲ್ಡರ್ (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender ಗಾಗಿ VRM Add-on ನಿಂದ ಎಕ್ಸ್‌ಪೋರ್ಟ್ ಮಾಡಿದ ಫೈಲ್‌ಗಳು ಸೇರಿ
- PNGTuber ಫೋಲ್ಡರ್: `closed.png`, `open.png` (ಐಚ್ಛಿಕ: `blink.png`, `blink-open.png`, `name.txt`)

ಪ್ಲೇ ಮಾಡಲಾಗದ ಫೈಲ್ (ಮೆಶ್ ಇಲ್ಲದ VRM, Draco / Meshopt / KTX2 ಸಂಕುಚನ, ತುಂಬಾ ದೊಡ್ಡ ಚಿತ್ರಗಳು) ಕಾರಣ ಸಹಿತ ತಿರಸ್ಕರಿಸಲಾಗುತ್ತದೆ.

## ಸ್ಥಳೀಕರಣ

- ಆ್ಯಪ್‌ನ ಪಠ್ಯ 50 ಭಾಷೆಗಳಲ್ಲಿ String Catalog ಗಳಲ್ಲಿ (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`) ಇದೆ. ಅಭಿವೃದ್ಧಿ ಭಾಷೆ ಇಂಗ್ಲಿಷ್, ಮತ್ತು ಇಂಗ್ಲಿಷ್‌ನ ಪ್ರಾದೇಶಿಕ ರೂಪಗಳೂ ಅದನ್ನೇ ಬಳಸುತ್ತವೆ.
- “ಪರವಾನಗಿಗಳು ಮತ್ತು ಟ್ರೇಡ್‌ಮಾರ್ಕ್‌ಗಳು” ದಾಖಲೆ ಕೊರಿಯನ್ ಸಾಧನಗಳಲ್ಲಿ ಕೊರಿಯನ್‌ನಲ್ಲಿ, ಬೇರೆಡೆ ಇಂಗ್ಲಿಷ್‌ನಲ್ಲಿ ಕಾಣುತ್ತದೆ. ಪಾತ್ರಗಳ ಹೆಸರು, ಶ್ರೇಯ ಮತ್ತು ಪರವಾನಗಿಗಳ ಮೂಲ ಪಠ್ಯವನ್ನು ಅನುವಾದಿಸುವುದಿಲ್ಲ.
- ಈ README ಇದೇ ಭಾಷೆಗಳಲ್ಲಿ ಲಭ್ಯವಿದೆ (ಮೇಲಿನ ಲಿಂಕ್‌ಗಳು). ಅನುವಾದಗಳನ್ನು ಇನ್ನೂ ಮಾತೃಭಾಷಿಕರು ಪರಿಶೀಲಿಸಿಲ್ಲ, ಆದ್ದರಿಂದ ತಿದ್ದುಪಡಿಗಳಿಗೆ ಸ್ವಾಗತ.

## ಪ್ರಾಜೆಕ್ಟ್ ರಚನೆ

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

## ಮೂಲ → ಪೋರ್ಟ್

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

## ಪರೀಕ್ಷೆಗಳು

```sh
cd Packages/LivLivKit
swift test
```

Linux ನಲ್ಲಿ ಪರಿಶೀಲಿಸಲಾಗಿದೆ: 21 ಒಳಗೊಂಡ ಪಾತ್ರಗಳನ್ನು ಓದುವುದು ಮತ್ತು ಪ್ರತಿಯೊಂದರ 240 ಫ್ರೇಮ್ ಪ್ಲೇ ಮಾಡುವುದು (ಭಾವಗಳು, ಕ್ರಿಯೆಗಳು, ಬಾಯಿ, ಐರಿಸ್ ಸ್ಟೆನ್ಸಿಲ್), keyforms, ಸರಪಳಿಗಳ ಪುಟಿತ, ZIP, ಲಿಪ್ ಸಿಂಕ್ ವಿಶ್ಲೇಷಣೆ, VRM 0.x / 1.0 ಓದುವುದು ಮತ್ತು ತಿರಸ್ಕರಿಸುವುದು, skinning, morphs ಮತ್ತು spring bones, ಮತ್ತು Blender ಗಾಗಿ VRM Add-on ಬರೆಯುವುದು (ಹೆಸರಿದ್ದರೂ ಬಳಸದ ಸಂಕುಚನ, `KHR_texture_transform`, samplers).

## ತಿಳಿದ ವ್ಯತ್ಯಾಸಗಳು ಮತ್ತು ಮಿತಿಗಳು

- **MToon** ಅನ್ನು RealityKit ನ ಬೆಳಕಿಲ್ಲದ ಮೆಟೀರಿಯಲ್‌ನಿಂದ ಅಂದಾಜಿಸಲಾಗುತ್ತದೆ (ಮೂಲ ಬಣ್ಣ, ಟೆಕ್ಸ್ಚರ್, ಆಲ್ಫಾ ಮೋಡ್, ಎರಡು ಬದಿ). ರಿಮ್ ಲೈಟ್ ಮತ್ತು ನೆರಳಿನ ಗಡಿ ಇಲ್ಲ.
- **VRM** ನಲ್ಲಿ skinning ಮತ್ತು morphs ಅನ್ನು CPU ನಲ್ಲಿ ಲೆಕ್ಕಹಾಕಿ ಪ್ರತಿ ಫ್ರೇಮ್ LowLevelMesh ಗೆ ಬರೆಯಲಾಗುತ್ತದೆ. ತುಂಬಾ ಹೆಚ್ಚು ವರ್ಟೆಕ್ಸ್ ಇರುವ ಮಾದರಿಗಳಿಗೆ Release ಬಿಲ್ಡ್ ಬಳಸಿ.
- **ಮುಖ ಟ್ರ್ಯಾಕಿಂಗ್** ARKit (TrueDepth) ಬಳಸುತ್ತದೆ, ಆದ್ದರಿಂದ Mac ಮತ್ತು Vision Pro ನಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ. ತುಟಿಗಳ ಲ್ಯಾಂಡ್‌ಮಾರ್ಕ್ ಇಲ್ಲದ ಕಾರಣ ಬಾಯಿ ತೆರೆಯುವುದನ್ನು `jawOpen` ಮಾತ್ರ ನಿರ್ಧರಿಸುತ್ತದೆ.
- **visionOS**: VRM ವಿಂಡೋದಲ್ಲಿ ಸುಮಾರು 0.36 m ಎತ್ತರವಿರುತ್ತದೆ.

## ಪರವಾನಗಿ

- ಕೋಡ್: LivLiv Player ನಂತೆಯೇ Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`).
- ಒಳಗೊಂಡ ಪಾತ್ರಗಳು: ಇವುಗಳಿಗೆ Apache ಪರವಾನಗಿ **ಅನ್ವಯಿಸುವುದಿಲ್ಲ**. ವಾಣಿಜ್ಯೇತರ ಬಳಕೆಗೆ ಮಾತ್ರ, ಶ್ರೇಯದೊಂದಿಗೆ. Kujira ಮತ್ತು Kujira Q CC BY-NC-SA 4.0 ಅಡಿಯಲ್ಲಿವೆ, ಮತ್ತು Pen ಗೆ ಯಾವುದೇ ಹಕ್ಕು ನೀಡಿಲ್ಲ. ವಿತರಿಸುವ ಮೊದಲು ಆ್ಯಪ್‌ನಲ್ಲಿ “ಪರವಾನಗಿಗಳು ಮತ್ತು ಟ್ರೇಡ್‌ಮಾರ್ಕ್‌ಗಳು” ಓದಿ.
- LivLiv ಹೆಸರು ಮತ್ತು ಲೋಗೊ ಯಾವುದೇ ಪರವಾನಗಿಯಲ್ಲಿ ಸೇರಿಲ್ಲ.
