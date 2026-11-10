# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · **മലയാളം** · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

വെബിനുള്ള 2.5D കഥാപാത്ര പ്ലേയറായ [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2) **iOS, macOS, visionOS എന്നിവയ്ക്കുള്ള നേറ്റീവ് ആപ്പാക്കി** മാറ്റുന്ന പ്രോജക്റ്റാണിത്. കഥാപാത്രങ്ങളെ **Metal** ഉപയോഗിച്ചും VRM അവതാറുകളെ ഈ പ്രോജക്റ്റിനായി **RealityKit**-ൽ എഴുതിയ glTF/VRM ലോഡർ ഉപയോഗിച്ചും വരയ്ക്കുന്നു.

## ആവശ്യകതകൾ

- iOS 18, macOS 15 അല്ലെങ്കിൽ visionOS 2 അല്ലെങ്കിൽ പുതിയത് (Xcode 16 അല്ലെങ്കിൽ പുതിയത്, Swift 6 ടൂൾചെയിൻ)
- ബാഹ്യ ആശ്രിതത്വങ്ങളില്ല. ആപ്പിന്റെ ലോജിക് ഒരു ലോക്കൽ Swift പാക്കേജിലാണ് (`Packages/LivLivKit`).

## ബിൽഡ്

1. Xcode-ൽ `livlivIOSPlayer.xcodeproj` തുറക്കുക.
2. Signing & Capabilities-ൽ നിങ്ങളുടെ Team തിരഞ്ഞെടുക്കുക, ആവശ്യമെങ്കിൽ ബണ്ടിൽ ഐഡന്റിഫയർ മാറ്റുക.
3. റൺ ലക്ഷ്യമായി iPhone അല്ലെങ്കിൽ iPad (ഉപകരണം അല്ലെങ്കിൽ സിമുലേറ്റർ), My Mac അല്ലെങ്കിൽ Apple Vision Pro തിരഞ്ഞെടുത്ത് Run (⌘R) അമർത്തുക.

`LivLivCore` Debug-ലും `-O` ഉപയോഗിച്ച് ബിൽഡ് ചെയ്യുന്നു, കാരണം റിഗ് ഓരോ ഫ്രെയിമിലും പതിനായിരക്കണക്കിന് വെർട്ടക്സുകൾ നീക്കുന്നു (k01: `-Onone`-ൽ ഒരു ഫ്രെയിമിന് ഏകദേശം 17 ms, `-O`-ൽ ഏകദേശം 2 ms).

## സവിശേഷതകൾ

- **കഥാപാത്രങ്ങൾ**: ഉൾപ്പെടുത്തിയ 21 കഥാപാത്രങ്ങൾ
- **ഇംപോർട്ട്**: ആപ്പിന്റെ Documents ഫോൾഡറിൽ നിങ്ങൾ വച്ച ഫോൾഡറോ ഫയലോ തിരഞ്ഞെടുക്കുക. ആപ്പ് ആദ്യം അത് തുറക്കാനാകുമോ എന്ന് പരിശോധിച്ച് പിന്നീട് ലോഡ് ചെയ്യുന്നു. കഴിയില്ലെങ്കിൽ, തിരഞ്ഞെടുത്ത് പകർത്താവുന്ന ടെക്സ്റ്റ് വ്യൂവിൽ ഒരു മുന്നറിയിപ്പ് കാരണം കാണിക്കുന്നു.
- Documents ഫോൾഡർ: iPhone, iPad, Vision Pro എന്നിവയിൽ ഫയലുകൾ › എന്റെ iPhone-ൽ › livlivIOSPlayer; Mac-ൽ ഇംപോർട്ട്-ലെ “Finder-ൽ Documents ഫോൾഡർ തുറക്കുക”. “മറ്റൊരു സ്ഥലത്ത് നിന്ന് തിരഞ്ഞെടുക്കുക…” മറ്റൊരിടത്തെ ഫോൾഡറോ ഫയലോ തുറക്കുന്നു.
- ഭാവങ്ങൾ, പ്രവൃത്തികൾ, മയക്കം. കഥാപാത്രം പോയിന്ററിനെ പിന്തുടരുന്നു, ആടുന്ന ഭാഗങ്ങൾ തൊടുമ്പോൾ തുള്ളുന്നു, പിഞ്ച് ചെയ്ത് സൂം ചെയ്യാം.
- മൈക്രോഫോണിൽ നിന്നോ ഓഡിയോ ഫയലിൽ നിന്നോ **ലിപ് സിങ്ക്**, TrueDepth ഉള്ള iPhone-ലോ iPad-ലോ **മുഖം ട്രാക്കിംഗ്**
- **ക്രമീകരണങ്ങൾ**: ചലനം, റെസല്യൂഷൻ, മുഖം ട്രാക്കിംഗ്, ഓപ്പൺ സോഴ്സ് ലൈസൻസുകൾ › “ലൈസൻസുകളും ട്രേഡ്‌മാർക്കുകളും”

## പിന്തുണയ്ക്കുന്ന ഫോർമാറ്റുകൾ

- LivLiv മോഡൽ ഫോൾഡർ (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender-നുള്ള VRM Add-on ഉപയോഗിച്ച് എക്സ്പോർട്ട് ചെയ്ത ഫയലുകൾ ഉൾപ്പെടെ
- PNGTuber ഫോൾഡർ: `closed.png`, `open.png` (ഓപ്ഷണൽ: `blink.png`, `blink-open.png`, `name.txt`)

പ്ലേ ചെയ്യാനാകാത്ത ഫയൽ (മെഷ് ഇല്ലാത്ത VRM, Draco / Meshopt / KTX2 കംപ്രഷൻ, വളരെ വലിയ ചിത്രങ്ങൾ) കാരണം സഹിതം നിരസിക്കുന്നു.

## പ്രാദേശികവൽക്കരണം

- ആപ്പിന്റെ ടെക്സ്റ്റ് 50 ഭാഷകളിൽ String Catalog-കളിലാണ് (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). വികസന ഭാഷ ഇംഗ്ലീഷാണ്, ഇംഗ്ലീഷിന്റെ പ്രാദേശിക രൂപങ്ങളും അതുതന്നെ ഉപയോഗിക്കുന്നു.
- “ലൈസൻസുകളും ട്രേഡ്‌മാർക്കുകളും” പ്രമാണം കൊറിയൻ ഉപകരണങ്ങളിൽ കൊറിയനിലും മറ്റിടങ്ങളിൽ ഇംഗ്ലീഷിലും കാണിക്കുന്നു. കഥാപാത്രങ്ങളുടെ പേരുകൾ, കടപ്പാട്, ലൈസൻസുകളുടെ യഥാർത്ഥ പാഠം എന്നിവ വിവർത്തനം ചെയ്യുന്നില്ല.
- ഈ README ഇതേ ഭാഷകളിൽ ലഭ്യമാണ് (മുകളിലെ ലിങ്കുകൾ). വിവർത്തനങ്ങൾ ഇതുവരെ മാതൃഭാഷക്കാർ പരിശോധിച്ചിട്ടില്ല, അതിനാൽ തിരുത്തലുകൾ സ്വാഗതം.

## പ്രോജക്റ്റ് ഘടന

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

## യഥാർത്ഥം → പോർട്ട്

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

## ടെസ്റ്റുകൾ

```sh
cd Packages/LivLivKit
swift test
```

Linux-ൽ പരിശോധിച്ചത്: ഉൾപ്പെടുത്തിയ 21 കഥാപാത്രങ്ങളെ വായിക്കലും ഓരോന്നിന്റെയും 240 ഫ്രെയിം പ്ലേ ചെയ്യലും (ഭാവങ്ങൾ, പ്രവൃത്തികൾ, വായ, ഐറിസ് സ്റ്റെൻസിൽ), keyforms, ചങ്ങലകളുടെ തുള്ളൽ, ZIP, ലിപ് സിങ്ക് വിശകലനം, VRM 0.x / 1.0 വായിക്കലും നിരസിക്കലും, skinning, morphs, spring bones, Blender-നുള്ള VRM Add-on എഴുതുന്നവ (പേരുണ്ടെങ്കിലും ഉപയോഗിക്കാത്ത കംപ്രഷൻ, `KHR_texture_transform`, samplers).

## അറിയപ്പെടുന്ന വ്യത്യാസങ്ങളും പരിമിതികളും

- **MToon** RealityKit-ന്റെ പ്രകാശമില്ലാത്ത മെറ്റീരിയൽ ഉപയോഗിച്ച് ഏകദേശമാക്കുന്നു (അടിസ്ഥാന നിറം, ടെക്സ്ചർ, ആൽഫ മോഡ്, ഇരുവശം). റിം ലൈറ്റും നിഴൽ അതിരും ഇല്ല.
- **VRM**-ൽ skinning-ഉം morphs-ഉം CPU-ൽ കണക്കാക്കി ഓരോ ഫ്രെയിമിലും LowLevelMesh-ലേക്ക് എഴുതുന്നു. വളരെയധികം വെർട്ടക്സുകളുള്ള മോഡലുകൾക്ക് Release ബിൽഡ് ഉപയോഗിക്കുക.
- **മുഖം ട്രാക്കിംഗ്** ARKit (TrueDepth) ഉപയോഗിക്കുന്നതിനാൽ Mac-ലും Vision Pro-ലും ലഭ്യമല്ല. ചുണ്ടുകളുടെ ലാൻഡ്മാർക്കുകൾ ഇല്ലാത്തതിനാൽ വായ തുറക്കൽ `jawOpen` മാത്രം നിർണ്ണയിക്കുന്നു.
- **visionOS**: VRM വിൻഡോയിൽ ഏകദേശം 0.36 m ഉയരത്തിൽ നിൽക്കുന്നു.

## ലൈസൻസ്

- കോഡ്: LivLiv Player-ന്റെ അതേ Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`).
- ഉൾപ്പെടുത്തിയ കഥാപാത്രങ്ങൾ: ഇവയ്ക്ക് Apache ലൈസൻസ് **ബാധകമല്ല**. വാണിജ്യേതര ഉപയോഗത്തിന് മാത്രം, കടപ്പാട് സഹിതം. Kujira, Kujira Q എന്നിവ CC BY-NC-SA 4.0 ആണ്, Pen-ന് ഒരു അവകാശവും നൽകിയിട്ടില്ല. വിതരണം ചെയ്യുന്നതിന് മുമ്പ് ആപ്പിലെ “ലൈസൻസുകളും ട്രേഡ്‌മാർക്കുകളും” വായിക്കുക.
- LivLiv പേരും ലോഗോയും ഒരു ലൈസൻസിലും ഉൾപ്പെടുന്നില്ല.
