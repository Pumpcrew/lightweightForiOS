# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · **Dansk** · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Dette projekt overfører [LivLiv Player](https://github.com/livliv-dev/player), en 2.5D-figurafspiller til nettet (TypeScript/WebGL2), til en **indbygget app til iOS, macOS og visionOS**. Figurer tegnes med **Metal**, og VRM-avatarer med en glTF/VRM-indlæser, der er skrevet til projektet oven på **RealityKit**.

## Krav

- iOS 18, macOS 15 eller visionOS 2 eller nyere (Xcode 16 eller nyere, Swift 6-værktøjskæde)
- Ingen eksterne afhængigheder. Appens logik ligger i en lokal Swift-pakke (`Packages/LivLivKit`).

## Byg

1. Åbn `livlivIOSPlayer.xcodeproj` i Xcode.
2. Vælg dit eget Team under Signing & Capabilities, og skift pakke-id’et, hvis det er nødvendigt.
3. Vælg en iPhone eller iPad (enhed eller simulator), My Mac eller Apple Vision Pro som mål, og tryk på Run (⌘R).

`LivLivCore` bygges med `-O` også i Debug, fordi riggen flytter titusindvis af punkter pr. billede (k01: ca. 17 ms pr. billede med `-Onone`, ca. 2 ms med `-O`).

## Funktioner

- **Figurer**: 21 medfølgende figurer
- **Importér**: vælg en mappe eller fil, du har lagt i appens mappe Documents. Appen tjekker først, at den kan åbne den, og indlæser den derefter. Hvis det ikke kan lade sig gøre, viser en advarsel årsagen i en tekstvisning, du kan markere og kopiere.
- Mappen Documents: på iPhone, iPad og Vision Pro under Arkiver › På min iPhone › livlivIOSPlayer; på Mac med “Åbn mappen Documents i Finder” i Importér. “Vælg fra en anden placering …” åbner en mappe eller fil et andet sted.
- Ansigtsudtryk, handlinger og døs. Figuren følger markøren, dele der svinger, fjedrer når du trykker, og du kan knibe for at zoome.
- **Læbesynkronisering** fra mikrofonen eller en lydfil og **ansigtssporing** på en iPhone eller iPad med TrueDepth
- **Indstillinger**: bevægelse, opløsning, ansigtssporing og Open source-licenser › “Licenser og varemærker”

## Understøttede formater

- LivLiv-modelmappe (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), også filer eksporteret med VRM Add-on til Blender
- PNGTuber-mappe: `closed.png`, `open.png` (valgfrit: `blink.png`, `blink-open.png`, `name.txt`)

En fil, der ikke kan afspilles (en VRM uden mesh, Draco-/Meshopt-/KTX2-komprimering, for store billeder), afvises med årsagen.

## Lokalisering

- Appens tekster findes på 50 sprog i String Catalogs (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Udviklingssproget er engelsk, og regionale varianter af engelsk bruger det.
- Dokumentet “Licenser og varemærker” vises på koreansk på koreanske enheder og ellers på engelsk. Figurernes navne, krediteringer og licensernes originaltekster oversættes ikke.
- Denne README findes på de samme sprog (links øverst). Oversættelserne er endnu ikke gennemgået af modersmålstalende, så rettelser er velkomne.

## Projektets opbygning

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

## Original → portering

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

## Test

```sh
cd Packages/LivLivKit
swift test
```

Kontrolleret på Linux: indlæsning af de 21 medfølgende figurer og 240 billeder af hver (udtryk, handlinger, mund, iris-stencil), keyforms, fjedrende kæder, ZIP, analyse til læbesynkronisering, indlæsning og afvisning af VRM 0.x / 1.0, skinning, morphs og spring bones samt det, VRM Add-on til Blender skriver (komprimering, der nævnes men ikke bruges, `KHR_texture_transform`, samplers).

## Kendte forskelle og begrænsninger

- **MToon** efterlignes med RealityKits ubelyste materiale (grundfarve, tekstur, alfatilstand, dobbeltsidethed). Der er hverken kantlys eller skyggegrænse.
- For **VRM** beregnes skinning og morphs på CPU’en og skrives til en LowLevelMesh hvert billede. Brug et Release-build til modeller med meget mange punkter.
- **Ansigtssporing** bruger ARKit (TrueDepth) og findes derfor ikke på Mac eller Vision Pro. Uden læbemarkører styres mundens åbning kun af `jawOpen`.
- **visionOS**: en VRM er ca. 0,36 m høj i vinduet.

## Licens

- Kode: Apache License 2.0, den samme som LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Medfølgende figurer: Apache-licensen gælder **ikke**. Kun ikke-kommerciel brug, med kreditering. Kujira og Kujira Q er under CC BY-NC-SA 4.0, og Pen gives ingen rettigheder. Læs “Licenser og varemærker” i appen, før du distribuerer den.
- Navnet og logoet LivLiv er ikke omfattet af nogen licens.
