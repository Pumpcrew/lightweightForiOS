# livlivIOSPlayer

**English** · [한국어](docs/readme/README.ko.md) · [日本語](docs/readme/README.ja.md) · [简体中文](docs/readme/README.zh-Hans.md) · [繁體中文](docs/readme/README.zh-Hant.md) · [繁體中文（香港）](docs/readme/README.zh-HK.md) · [Español](docs/readme/README.es.md) · [Español (Latinoamérica)](docs/readme/README.es-419.md) · [Français](docs/readme/README.fr.md) · [Français (Canada)](docs/readme/README.fr-CA.md) · [Deutsch](docs/readme/README.de.md) · [Italiano](docs/readme/README.it.md) · [Português (Brasil)](docs/readme/README.pt-BR.md) · [Português (Portugal)](docs/readme/README.pt-PT.md) · [Nederlands](docs/readme/README.nl.md) · [Svenska](docs/readme/README.sv.md) · [Dansk](docs/readme/README.da.md) · [Norsk bokmål](docs/readme/README.nb.md) · [Suomi](docs/readme/README.fi.md) · [Polski](docs/readme/README.pl.md) · [Čeština](docs/readme/README.cs.md) · [Slovenčina](docs/readme/README.sk.md) · [Slovenščina](docs/readme/README.sl.md) · [Hrvatski](docs/readme/README.hr.md) · [Русский](docs/readme/README.ru.md) · [Українська](docs/readme/README.uk.md) · [Български](docs/readme/README.bg.md) · [Қазақ тілі](docs/readme/README.kk.md) · [Ελληνικά](docs/readme/README.el.md) · [Română](docs/readme/README.ro.md) · [Magyar](docs/readme/README.hu.md) · [Lietuvių](docs/readme/README.lt.md) · [Türkçe](docs/readme/README.tr.md) · [Català](docs/readme/README.ca.md) · [العربية](docs/readme/README.ar.md) · [עברית](docs/readme/README.he.md) · [اردو](docs/readme/README.ur.md) · [हिन्दी](docs/readme/README.hi.md) · [বাংলা](docs/readme/README.bn.md) · [ગુજરાતી](docs/readme/README.gu.md) · [ಕನ್ನಡ](docs/readme/README.kn.md) · [മലയാളം](docs/readme/README.ml.md) · [मराठी](docs/readme/README.mr.md) · [ଓଡ଼ିଆ](docs/readme/README.or.md) · [ਪੰਜਾਬੀ](docs/readme/README.pa.md) · [தமிழ்](docs/readme/README.ta.md) · [తెలుగు](docs/readme/README.te.md) · [ไทย](docs/readme/README.th.md) · [Tiếng Việt](docs/readme/README.vi.md) · [Bahasa Indonesia](docs/readme/README.id.md) · [Bahasa Melayu](docs/readme/README.ms.md)

A port of [LivLiv Player](https://github.com/livliv-dev/player), a 2.5D character player for the web (TypeScript/WebGL2), to a **native app for iOS, macOS and visionOS**. Characters are drawn with **Metal**, and VRM avatars with a glTF/VRM loader written for this project on **RealityKit**.

## Requirements

- iOS 18, macOS 15 or visionOS 2 or later (Xcode 16 or later, Swift 6 toolchain)
- No outside dependencies. The app's logic is in a local Swift package (`Packages/LivLivKit`).

## Build

1. Open `livlivIOSPlayer.xcodeproj` in Xcode.
2. In Signing & Capabilities, choose your own Team, and change the bundle identifier if you need to.
3. Choose an iPhone or iPad (device or simulator), My Mac or Apple Vision Pro as the run destination, then press Run (⌘R).

`LivLivCore` is built with `-O` even in Debug, because the rig moves tens of thousands of vertices each frame (k01: about 17 ms a frame at `-Onone`, about 2 ms at `-O`).

## Features

- **Characters**: 21 bundled characters
- **Import**: pick a folder or file you put in the app's Documents folder. The app first checks that it can open it, then loads it. If it can't, an alert shows the reason in a text view you can select and copy.
- Documents folder: on iPhone, iPad and Vision Pro, Files › On My iPhone › livlivIOSPlayer; on Mac, “Open the Documents Folder in Finder” in Import. “Choose from Another Location…” opens a folder or file somewhere else.
- Expressions, actions and dozing. The character follows the pointer, swinging parts bounce when tapped, and you can pinch to zoom.
- **Lip sync** from the microphone or an audio file, and **face tracking** on an iPhone or iPad with TrueDepth
- **Settings**: motion, resolution, face tracking, and Open Source Licenses › “Licenses and Trademarks”

## Supported formats

- LivLiv model folder (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), including files exported by the VRM Add-on for Blender
- PNGTuber folder: `closed.png`, `open.png` (optional: `blink.png`, `blink-open.png`, `name.txt`)

A file that can't be played (a VRM with no mesh, Draco / Meshopt / KTX2 compression, images that are too large) is refused with the reason.

## Localization

- The app's text is in 50 languages, in String Catalogs (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). The development language is English, and regional variants of English use it.
- The “Licenses and Trademarks” document is in Korean on Korean devices and in English elsewhere. Character names, credits and original license texts are not translated.
- This README is in the same languages (links at the top). The translations have not yet been reviewed by native speakers, so corrections are welcome.

## Project layout

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

## Original → port

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

## Tests

```sh
cd Packages/LivLivKit
swift test
```

Checked on Linux: reading the 21 bundled characters, 240 frames of each (expressions, actions, mouth, iris stencil), keyforms, chain bounce, ZIP, lip-sync analysis, reading and refusing VRM 0.x / 1.0, skinning, morphs and spring bones, and what the VRM Add-on for Blender writes (compression named but not used, `KHR_texture_transform`, samplers).

## Known differences and limits

- **MToon** is approximated with RealityKit's unlit material (base colour, texture, alpha mode, double-sidedness). There is no rim light or shade boundary.
- **VRM** skinning and morphs run on the CPU and are written to a LowLevelMesh each frame. Use a Release build for models with very many vertices.
- **Face tracking** uses ARKit (TrueDepth), so it is not available on Mac or Vision Pro. With no lip landmarks, mouth opening comes from `jawOpen` alone.
- **visionOS**: a VRM stands about 0.36 m tall in the window.

## License

- Code: Apache License 2.0, the same as LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Bundled characters: the Apache license does **not** apply. Non-commercial use only, with credit. Kujira and Kujira Q are CC BY-NC-SA 4.0, and Pen is given no rights at all. Read “Licenses and Trademarks” in the app before you distribute it.
- The LivLiv name and logo are not covered by any license.
