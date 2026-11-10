# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · **ਪੰਜਾਬੀ** · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

ਇਹ ਪ੍ਰੋਜੈਕਟ ਵੈੱਬ ਲਈ ਬਣੇ 2.5D ਕਿਰਦਾਰ ਪਲੇਅਰ [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2) ਨੂੰ **iOS, macOS ਅਤੇ visionOS ਦੀ ਨੇਟਿਵ ਐਪ** ਵਿੱਚ ਬਦਲਦਾ ਹੈ। ਕਿਰਦਾਰ **Metal** ਨਾਲ ਬਣਾਏ ਜਾਂਦੇ ਹਨ, ਅਤੇ VRM ਅਵਤਾਰ ਇਸ ਪ੍ਰੋਜੈਕਟ ਲਈ **RealityKit** ਉੱਤੇ ਲਿਖੇ glTF/VRM ਲੋਡਰ ਨਾਲ।

## ਲੋੜਾਂ

- iOS 18, macOS 15 ਜਾਂ visionOS 2 ਜਾਂ ਬਾਅਦ ਵਾਲਾ (Xcode 16 ਜਾਂ ਬਾਅਦ ਵਾਲਾ, Swift 6 ਟੂਲਚੇਨ)
- ਕੋਈ ਬਾਹਰੀ ਨਿਰਭਰਤਾ ਨਹੀਂ। ਐਪ ਦਾ ਲੌਜਿਕ ਇੱਕ ਸਥਾਨਕ Swift ਪੈਕੇਜ (`Packages/LivLivKit`) ਵਿੱਚ ਹੈ।

## ਬਿਲਡ

1. Xcode ਵਿੱਚ `livlivIOSPlayer.xcodeproj` ਖੋਲ੍ਹੋ।
2. Signing & Capabilities ਵਿੱਚ ਆਪਣੀ Team ਚੁਣੋ, ਅਤੇ ਲੋੜ ਹੋਵੇ ਤਾਂ ਬੰਡਲ ਪਛਾਣਕਰਤਾ ਬਦਲੋ।
3. ਚਲਾਉਣ ਦੀ ਮੰਜ਼ਿਲ ਵਜੋਂ iPhone ਜਾਂ iPad (ਡੀਵਾਈਸ ਜਾਂ ਸਿਮੂਲੇਟਰ), My Mac ਜਾਂ Apple Vision Pro ਚੁਣੋ, ਫਿਰ Run (⌘R) ਦਬਾਓ।

`LivLivCore` Debug ਵਿੱਚ ਵੀ `-O` ਨਾਲ ਬਿਲਡ ਹੁੰਦਾ ਹੈ, ਕਿਉਂਕਿ ਰਿਗ ਹਰ ਫ੍ਰੇਮ ਵਿੱਚ ਹਜ਼ਾਰਾਂ ਵਰਟੈਕਸ ਹਿਲਾਉਂਦਾ ਹੈ (k01: `-Onone` ਉੱਤੇ ਪ੍ਰਤੀ ਫ੍ਰੇਮ ਲਗਭਗ 17 ms, `-O` ਉੱਤੇ ਲਗਭਗ 2 ms)।

## ਵਿਸ਼ੇਸ਼ਤਾਵਾਂ

- **ਕਿਰਦਾਰ**: 21 ਸ਼ਾਮਲ ਕਿਰਦਾਰ
- **ਇੰਪੋਰਟ ਕਰੋ**: ਐਪ ਦੇ Documents ਫੋਲਡਰ ਵਿੱਚ ਰੱਖਿਆ ਫੋਲਡਰ ਜਾਂ ਫ਼ਾਈਲ ਚੁਣੋ। ਐਪ ਪਹਿਲਾਂ ਜਾਂਚਦੀ ਹੈ ਕਿ ਉਹ ਇਸਨੂੰ ਖੋਲ੍ਹ ਸਕਦੀ ਹੈ, ਫਿਰ ਲੋਡ ਕਰਦੀ ਹੈ। ਨਾ ਖੋਲ੍ਹ ਸਕੇ ਤਾਂ ਇੱਕ ਚਿਤਾਵਨੀ ਕਾਰਨ ਨੂੰ ਅਜਿਹੇ ਟੈਕਸਟ ਵਿਊ ਵਿੱਚ ਦਿਖਾਉਂਦੀ ਹੈ ਜਿਸਨੂੰ ਚੁਣਿਆ ਅਤੇ ਕਾਪੀ ਕੀਤਾ ਜਾ ਸਕਦਾ ਹੈ।
- Documents ਫੋਲਡਰ: iPhone, iPad ਅਤੇ Vision Pro ਉੱਤੇ ਫ਼ਾਈਲਾਂ › ਮੇਰੇ iPhone ਉੱਤੇ › livlivIOSPlayer; Mac ਉੱਤੇ ਇੰਪੋਰਟ ਕਰੋ ਵਿੱਚ “Finder ਵਿੱਚ Documents ਫੋਲਡਰ ਖੋਲ੍ਹੋ”। “ਕਿਸੇ ਹੋਰ ਥਾਂ ਤੋਂ ਚੁਣੋ…” ਕਿਸੇ ਹੋਰ ਥਾਂ ਦਾ ਫੋਲਡਰ ਜਾਂ ਫ਼ਾਈਲ ਖੋਲ੍ਹਦਾ ਹੈ।
- ਹਾਵ-ਭਾਵ, ਕਿਰਿਆਵਾਂ ਅਤੇ ਊਂਘ। ਕਿਰਦਾਰ ਪੁਆਇੰਟਰ ਦੇ ਪਿੱਛੇ ਦੇਖਦਾ ਹੈ, ਝੂਲਦੇ ਹਿੱਸੇ ਛੂਹਣ ਉੱਤੇ ਉੱਛਲਦੇ ਹਨ, ਅਤੇ ਪਿੰਚ ਕਰਕੇ ਜ਼ੂਮ ਕੀਤਾ ਜਾ ਸਕਦਾ ਹੈ।
- ਮਾਈਕ੍ਰੋਫ਼ੋਨ ਜਾਂ ਆਡੀਓ ਫ਼ਾਈਲ ਤੋਂ **ਲਿਪ ਸਿੰਕ**, ਅਤੇ TrueDepth ਵਾਲੇ iPhone ਜਾਂ iPad ਉੱਤੇ **ਚਿਹਰਾ ਟਰੈਕਿੰਗ**
- **ਸੈਟਿੰਗਾਂ**: ਹਿਲਜੁਲ, ਰੈਜ਼ੋਲਿਊਸ਼ਨ, ਚਿਹਰਾ ਟਰੈਕਿੰਗ, ਅਤੇ ਓਪਨ ਸੋਰਸ ਲਾਇਸੰਸ › “ਲਾਇਸੰਸ ਅਤੇ ਟ੍ਰੇਡਮਾਰਕ”

## ਸਮਰਥਿਤ ਫਾਰਮੈਟ

- LivLiv ਮਾਡਲ ਫੋਲਡਰ (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender ਲਈ VRM Add-on ਨਾਲ ਐਕਸਪੋਰਟ ਕੀਤੀਆਂ ਫ਼ਾਈਲਾਂ ਸਮੇਤ
- PNGTuber ਫੋਲਡਰ: `closed.png`, `open.png` (ਵਿਕਲਪਿਕ: `blink.png`, `blink-open.png`, `name.txt`)

ਜੋ ਫ਼ਾਈਲ ਚਲਾਈ ਨਹੀਂ ਜਾ ਸਕਦੀ (ਮੈਸ਼ ਤੋਂ ਬਿਨਾਂ VRM, Draco / Meshopt / KTX2 ਕੰਪ੍ਰੈਸ਼ਨ, ਬਹੁਤ ਵੱਡੀਆਂ ਤਸਵੀਰਾਂ) ਉਸਨੂੰ ਕਾਰਨ ਦੱਸ ਕੇ ਰੱਦ ਕੀਤਾ ਜਾਂਦਾ ਹੈ।

## ਸਥਾਨੀਕਰਨ

- ਐਪ ਦੀ ਲਿਖਤ 50 ਭਾਸ਼ਾਵਾਂ ਵਿੱਚ String Catalogs (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`) ਵਿੱਚ ਹੈ। ਵਿਕਾਸ ਭਾਸ਼ਾ ਅੰਗਰੇਜ਼ੀ ਹੈ, ਅਤੇ ਅੰਗਰੇਜ਼ੀ ਦੇ ਖੇਤਰੀ ਰੂਪ ਵੀ ਇਹੀ ਵਰਤਦੇ ਹਨ।
- “ਲਾਇਸੰਸ ਅਤੇ ਟ੍ਰੇਡਮਾਰਕ” ਦਸਤਾਵੇਜ਼ ਕੋਰੀਆਈ ਡੀਵਾਈਸਾਂ ਉੱਤੇ ਕੋਰੀਆਈ ਵਿੱਚ ਅਤੇ ਹੋਰ ਥਾਂ ਅੰਗਰੇਜ਼ੀ ਵਿੱਚ ਦਿਸਦਾ ਹੈ। ਕਿਰਦਾਰਾਂ ਦੇ ਨਾਮ, ਸਿਹਰਾ ਅਤੇ ਲਾਇਸੰਸਾਂ ਦੀ ਮੂਲ ਲਿਖਤ ਦਾ ਅਨੁਵਾਦ ਨਹੀਂ ਕੀਤਾ ਜਾਂਦਾ।
- ਇਹ README ਇਨ੍ਹਾਂ ਹੀ ਭਾਸ਼ਾਵਾਂ ਵਿੱਚ ਉਪਲਬਧ ਹੈ (ਉੱਪਰ ਲਿੰਕ)। ਅਨੁਵਾਦਾਂ ਦੀ ਅਜੇ ਮਾਂ-ਬੋਲੀ ਵਾਲਿਆਂ ਨੇ ਸਮੀਖਿਆ ਨਹੀਂ ਕੀਤੀ, ਇਸ ਲਈ ਸੁਧਾਰਾਂ ਦਾ ਸਵਾਗਤ ਹੈ।

## ਪ੍ਰੋਜੈਕਟ ਦੀ ਬਣਤਰ

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

## ਮੂਲ → ਪੋਰਟ

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

## ਟੈਸਟ

```sh
cd Packages/LivLivKit
swift test
```

Linux ਉੱਤੇ ਜਾਂਚਿਆ: 21 ਸ਼ਾਮਲ ਕਿਰਦਾਰਾਂ ਨੂੰ ਪੜ੍ਹਨਾ ਅਤੇ ਹਰ ਇੱਕ ਦੇ 240 ਫ੍ਰੇਮ ਚਲਾਉਣਾ (ਹਾਵ-ਭਾਵ, ਕਿਰਿਆਵਾਂ, ਮੂੰਹ, ਆਇਰਿਸ ਸਟੈਂਸਿਲ), keyforms, ਜ਼ੰਜੀਰਾਂ ਦਾ ਉੱਛਲਣਾ, ZIP, ਲਿਪ ਸਿੰਕ ਵਿਸ਼ਲੇਸ਼ਣ, VRM 0.x / 1.0 ਪੜ੍ਹਨਾ ਅਤੇ ਰੱਦ ਕਰਨਾ, skinning, morphs ਅਤੇ spring bones, ਅਤੇ Blender ਲਈ VRM Add-on ਜੋ ਲਿਖਦਾ ਹੈ (ਨਾਮ ਦਿੱਤਾ ਪਰ ਨਾ ਵਰਤਿਆ ਕੰਪ੍ਰੈਸ਼ਨ, `KHR_texture_transform`, samplers)।

## ਜਾਣੇ-ਪਛਾਣੇ ਫ਼ਰਕ ਅਤੇ ਸੀਮਾਵਾਂ

- **MToon** ਨੂੰ RealityKit ਦੇ ਬਿਨਾਂ ਰੋਸ਼ਨੀ ਵਾਲੇ ਮਟੀਰੀਅਲ ਨਾਲ ਅੰਦਾਜ਼ਨ ਦਿਖਾਇਆ ਜਾਂਦਾ ਹੈ (ਮੂਲ ਰੰਗ, ਟੈਕਸਚਰ, ਅਲਫ਼ਾ ਮੋਡ, ਦੋਵੇਂ ਪਾਸੇ)। ਰਿਮ ਲਾਈਟ ਅਤੇ ਪਰਛਾਵੇਂ ਦੀ ਹੱਦ ਨਹੀਂ ਹੈ।
- **VRM** ਵਿੱਚ skinning ਅਤੇ morphs CPU ਉੱਤੇ ਗਿਣੇ ਜਾਂਦੇ ਹਨ ਅਤੇ ਹਰ ਫ੍ਰੇਮ LowLevelMesh ਵਿੱਚ ਲਿਖੇ ਜਾਂਦੇ ਹਨ। ਬਹੁਤ ਜ਼ਿਆਦਾ ਵਰਟੈਕਸ ਵਾਲੇ ਮਾਡਲਾਂ ਲਈ Release ਬਿਲਡ ਵਰਤੋ।
- **ਚਿਹਰਾ ਟਰੈਕਿੰਗ** ARKit (TrueDepth) ਵਰਤਦੀ ਹੈ, ਇਸ ਲਈ Mac ਅਤੇ Vision Pro ਉੱਤੇ ਉਪਲਬਧ ਨਹੀਂ। ਬੁੱਲ੍ਹਾਂ ਦੇ ਨਿਸ਼ਾਨ ਨਾ ਹੋਣ ਕਰਕੇ ਮੂੰਹ ਖੁੱਲ੍ਹਣਾ ਸਿਰਫ਼ `jawOpen` ਤੋਂ ਤੈਅ ਹੁੰਦਾ ਹੈ।
- **visionOS**: VRM ਵਿੰਡੋ ਵਿੱਚ ਲਗਭਗ 0.36 m ਉੱਚਾ ਹੁੰਦਾ ਹੈ।

## ਲਾਇਸੰਸ

- ਕੋਡ: LivLiv Player ਵਾਂਗ Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`)।
- ਸ਼ਾਮਲ ਕਿਰਦਾਰ: ਇਨ੍ਹਾਂ ਉੱਤੇ Apache ਲਾਇਸੰਸ **ਲਾਗੂ ਨਹੀਂ** ਹੁੰਦਾ। ਸਿਰਫ਼ ਗੈਰ-ਵਪਾਰਕ ਵਰਤੋਂ, ਸਿਹਰੇ ਸਮੇਤ। Kujira ਅਤੇ Kujira Q CC BY-NC-SA 4.0 ਹੇਠ ਹਨ, ਅਤੇ Pen ਲਈ ਕੋਈ ਹੱਕ ਨਹੀਂ ਦਿੱਤਾ ਗਿਆ। ਵੰਡਣ ਤੋਂ ਪਹਿਲਾਂ ਐਪ ਵਿੱਚ “ਲਾਇਸੰਸ ਅਤੇ ਟ੍ਰੇਡਮਾਰਕ” ਪੜ੍ਹੋ।
- LivLiv ਨਾਮ ਅਤੇ ਲੋਗੋ ਕਿਸੇ ਲਾਇਸੰਸ ਵਿੱਚ ਸ਼ਾਮਲ ਨਹੀਂ ਹਨ।
