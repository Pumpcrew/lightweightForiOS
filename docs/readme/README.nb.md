# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · **Norsk bokmål** · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Dette prosjektet porterer [LivLiv Player](https://github.com/livliv-dev/player), en 2.5D-figurspiller for nettet (TypeScript/WebGL2), til en **innebygd app for iOS, macOS og visionOS**. Figurer tegnes med **Metal**, og VRM-avatarer med en glTF/VRM-laster som er skrevet for prosjektet oppå **RealityKit**.

## Krav

- iOS 18, macOS 15 eller visionOS 2 eller nyere (Xcode 16 eller nyere, Swift 6-verktøykjede)
- Ingen eksterne avhengigheter. Logikken i appen ligger i en lokal Swift-pakke (`Packages/LivLivKit`).

## Bygg

1. Åpne `livlivIOSPlayer.xcodeproj` i Xcode.
2. Velg ditt eget Team under Signing & Capabilities, og endre pakke-ID-en om nødvendig.
3. Velg en iPhone eller iPad (enhet eller simulator), My Mac eller Apple Vision Pro som mål, og trykk på Run (⌘R).

`LivLivCore` bygges med `-O` også i Debug, fordi riggen flytter titusenvis av punkter per bilde (k01: omtrent 17 ms per bilde med `-Onone`, omtrent 2 ms med `-O`).

## Funksjoner

- **Figurer**: 21 medfølgende figurer
- **Importer**: velg en mappe eller fil du har lagt i Documents-mappen til appen. Appen sjekker først at den kan åpne den, og laster den så inn. Hvis det ikke går, viser et varsel årsaken i en tekstvisning du kan markere og kopiere.
- Documents-mappen: på iPhone, iPad og Vision Pro under Filer › På min iPhone › livlivIOSPlayer; på Mac med «Åpne Documents-mappen i Finder» i Importer. «Velg fra et annet sted …» åpner en mappe eller fil et annet sted.
- Ansiktsuttrykk, handlinger og døsing. Figuren følger pekeren, deler som svinger, spretter når du trykker, og du kan knipe for å zoome.
- **Leppesynk** fra mikrofonen eller en lydfil, og **ansiktssporing** på en iPhone eller iPad med TrueDepth
- **Innstillinger**: bevegelse, oppløsning, ansiktssporing og Åpen kildekode-lisenser › «Lisenser og varemerker»

## Støttede formater

- LivLiv-modellmappe (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), også filer eksportert med VRM Add-on for Blender
- PNGTuber-mappe: `closed.png`, `open.png` (valgfritt: `blink.png`, `blink-open.png`, `name.txt`)

En fil som ikke kan spilles av (en VRM uten mesh, Draco-/Meshopt-/KTX2-komprimering, for store bilder), avvises med årsaken.

## Lokalisering

- Tekstene i appen finnes på 50 språk, i String Catalogs (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Utviklingsspråket er engelsk, og regionale varianter av engelsk bruker det.
- Dokumentet «Lisenser og varemerker» vises på koreansk på koreanske enheter og ellers på engelsk. Figurnavn, kreditering og originaltekstene til lisensene oversettes ikke.
- Denne README-en finnes på de samme språkene (lenker øverst). Oversettelsene er ennå ikke gjennomgått av morsmålsbrukere, så rettelser er velkomne.

## Prosjektstruktur

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

## Tester

```sh
cd Packages/LivLivKit
swift test
```

Kontrollert på Linux: innlesing av de 21 medfølgende figurene og 240 bilder av hver (uttrykk, handlinger, munn, iris-stencil), keyforms, sprettende kjeder, ZIP, analyse for leppesynk, innlesing og avvisning av VRM 0.x / 1.0, skinning, morphs og spring bones, og det VRM Add-on for Blender skriver (komprimering som nevnes, men ikke brukes, `KHR_texture_transform`, samplers).

## Kjente forskjeller og begrensninger

- **MToon** etterlignes med RealityKits ubelyste materiale (grunnfarge, tekstur, alfamodus, tosidighet). Det finnes verken kantlys eller skyggegrense.
- For **VRM** beregnes skinning og morphs på prosessoren og skrives til en LowLevelMesh hvert bilde. Bruk et Release-bygg for modeller med svært mange punkter.
- **Ansiktssporing** bruker ARKit (TrueDepth) og er derfor ikke tilgjengelig på Mac eller Vision Pro. Uten leppemarkører styres munnåpningen bare av `jawOpen`.
- **visionOS**: en VRM er omtrent 0,36 m høy i vinduet.

## Lisens

- Kode: Apache License 2.0, den samme som LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Medfølgende figurer: Apache-lisensen gjelder **ikke**. Kun ikke-kommersiell bruk, med kreditering. Kujira og Kujira Q er CC BY-NC-SA 4.0, og Pen gis ingen rettigheter. Les «Lisenser og varemerker» i appen før du distribuerer den.
- Navnet og logoen LivLiv dekkes ikke av noen lisens.
