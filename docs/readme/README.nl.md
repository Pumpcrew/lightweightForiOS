# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · **Nederlands** · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Dit project zet [LivLiv Player](https://github.com/livliv-dev/player), een 2.5D-personagespeler voor het web (TypeScript/WebGL2), om naar een **native app voor iOS, macOS en visionOS**. Personages worden getekend met **Metal**, VRM-avatars met een glTF/VRM-lader die voor dit project op **RealityKit** is geschreven.

## Vereisten

- iOS 18, macOS 15 of visionOS 2 of nieuwer (Xcode 16 of nieuwer, Swift 6-toolchain)
- Geen externe afhankelijkheden. De logica van de app staat in een lokaal Swift-pakket (`Packages/LivLivKit`).

## Bouwen

1. Open `livlivIOSPlayer.xcodeproj` in Xcode.
2. Kies bij Signing & Capabilities je eigen Team en wijzig zo nodig de bundel-ID.
3. Kies een iPhone of iPad (apparaat of simulator), My Mac of Apple Vision Pro als bestemming en druk op Run (⌘R).

`LivLivCore` wordt ook in Debug met `-O` gebouwd, omdat de rig elk frame tienduizenden hoekpunten verplaatst (k01: ongeveer 17 ms per frame met `-Onone`, ongeveer 2 ms met `-O`).

## Functies

- **Personages**: 21 meegeleverde personages
- **Importeer**: kies een map of bestand dat je in de map Documents van de app hebt gezet. De app controleert eerst of hij het kan openen en laadt het daarna. Lukt dat niet, dan toont een melding de reden in een tekstweergave die je kunt selecteren en kopiëren.
- Map Documents: op iPhone, iPad en Vision Pro via Bestanden › Op mijn iPhone › livlivIOSPlayer; op de Mac via 'Open de map Documents in de Finder' in Importeer. 'Kies van een andere locatie…' opent een map of bestand op een andere plek.
- Uitdrukkingen, acties en dutten. Het personage volgt de aanwijzer, bewegende delen veren mee als je erop tikt en je kunt knijpen om te zoomen.
- **Lipsynchronisatie** via de microfoon of een audiobestand, en **gezichtsherkenning** op een iPhone of iPad met TrueDepth
- **Instellingen**: beweging, resolutie, gezichtsherkenning en Opensourcelicenties › 'Licenties en handelsmerken'

## Ondersteunde formaten

- LivLiv-modelmap (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), ook bestanden die zijn geëxporteerd met de VRM Add-on voor Blender
- PNGTuber-map: `closed.png`, `open.png` (optioneel: `blink.png`, `blink-open.png`, `name.txt`)

Een bestand dat niet kan worden afgespeeld (een VRM zonder mesh, Draco-/Meshopt-/KTX2-compressie, te grote afbeeldingen) wordt met de reden geweigerd.

## Lokalisatie

- De teksten van de app zijn er in 50 talen, in String Catalogs (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). De ontwikkeltaal is Engels; regionale varianten van het Engels gebruiken die.
- Het document 'Licenties en handelsmerken' is in het Koreaans op Koreaanse apparaten en elders in het Engels. Namen van personages, credits en de originele licentieteksten worden niet vertaald.
- Deze README is er in dezelfde talen (links bovenaan). De vertalingen zijn nog niet door moedertaalsprekers nagekeken, dus correcties zijn welkom.

## Projectopbouw

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

## Origineel → port

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

Gecontroleerd op Linux: inlezen van de 21 meegeleverde personages en van elk 240 frames (uitdrukkingen, acties, mond, irisstencil), keyforms, verende ketens, ZIP, analyse voor lipsynchronisatie, inlezen en weigeren van VRM 0.x / 1.0, skinning, morphs en spring bones, en wat de VRM Add-on voor Blender schrijft (compressie die genoemd maar niet gebruikt wordt, `KHR_texture_transform`, samplers).

## Bekende verschillen en beperkingen

- **MToon** wordt benaderd met het onbelichte materiaal van RealityKit (basiskleur, textuur, alfamodus, dubbelzijdigheid). Er is geen randlicht of schaduwgrens.
- Bij **VRM** worden skinning en morphs op de CPU berekend en elk frame naar een LowLevelMesh geschreven. Gebruik een Release-build voor modellen met heel veel hoekpunten.
- **Gezichtsherkenning** gebruikt ARKit (TrueDepth) en is dus niet beschikbaar op Mac of Vision Pro. Zonder lipmarkeringen komt het openen van de mond alleen uit `jawOpen`.
- **visionOS**: een VRM is in het venster ongeveer 0,36 m hoog.

## Licentie

- Code: Apache License 2.0, net als LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Meegeleverde personages: de Apache-licentie geldt **niet**. Alleen niet-commercieel gebruik, met naamsvermelding. Kujira en Kujira Q vallen onder CC BY-NC-SA 4.0, en voor Pen worden geen rechten verleend. Lees 'Licenties en handelsmerken' in de app voordat je hem verspreidt.
- De naam en het logo LivLiv vallen onder geen enkele licentie.
