# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · **Svenska** · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Det här projektet porterar [LivLiv Player](https://github.com/livliv-dev/player), en 2.5D-figurspelare för webben (TypeScript/WebGL2), till en **inbyggd app för iOS, macOS och visionOS**. Figurer ritas med **Metal**, och VRM-avatarer med en glTF/VRM-laddare som skrivits för projektet ovanpå **RealityKit**.

## Krav

- iOS 18, macOS 15 eller visionOS 2 eller senare (Xcode 16 eller senare, Swift 6-verktygskedja)
- Inga externa beroenden. Appens logik finns i ett lokalt Swift-paket (`Packages/LivLivKit`).

## Bygga

1. Öppna `livlivIOSPlayer.xcodeproj` i Xcode.
2. Välj ditt eget Team under Signing & Capabilities och ändra paket-ID:t om det behövs.
3. Välj en iPhone eller iPad (enhet eller simulator), My Mac eller Apple Vision Pro som mål och tryck på Run (⌘R).

`LivLivCore` byggs med `-O` även i Debug, eftersom riggen flyttar tiotusentals hörn per bildruta (k01: cirka 17 ms per bildruta med `-Onone`, cirka 2 ms med `-O`).

## Funktioner

- **Figurer**: 21 medföljande figurer
- **Importera**: välj en mapp eller fil som du lagt i appens mapp Documents. Appen kontrollerar först att den kan öppna den och läser sedan in den. Om det inte går visar en varning orsaken i en textvy som du kan markera och kopiera.
- Mappen Documents: på iPhone, iPad och Vision Pro under Filer › På min iPhone › livlivIOSPlayer; på Mac med ”Öppna mappen Documents i Finder” i Importera. ”Välj från en annan plats …” öppnar en mapp eller fil någon annanstans.
- Ansiktsuttryck, handlingar och slummer. Figuren följer pekaren, delar som svänger studsar när du trycker och du kan nypa för att zooma.
- **Läppsynk** från mikrofonen eller en ljudfil, och **ansiktsspårning** på en iPhone eller iPad med TrueDepth
- **Inställningar**: rörelse, upplösning, ansiktsspårning och Licenser för öppen källkod › ”Licenser och varumärken”

## Format som stöds

- LivLiv-modellmapp (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), även filer som exporterats med VRM Add-on för Blender
- PNGTuber-mapp: `closed.png`, `open.png` (valfritt: `blink.png`, `blink-open.png`, `name.txt`)

En fil som inte kan spelas upp (en VRM utan mesh, Draco-/Meshopt-/KTX2-komprimering, för stora bilder) avvisas med orsaken.

## Lokalisering

- Appens texter finns på 50 språk, i String Catalogs (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Utvecklingsspråket är engelska, och regionala varianter av engelska använder det.
- Dokumentet ”Licenser och varumärken” visas på koreanska på koreanska enheter och på engelska i övrigt. Figurernas namn, erkännanden och licensernas originaltexter översätts inte.
- Den här README-filen finns på samma språk (länkar överst). Översättningarna har ännu inte granskats av modersmålstalare, så rättelser är välkomna.

## Projektets struktur

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

Kontrollerat på Linux: inläsning av de 21 medföljande figurerna och 240 bildrutor av var och en (uttryck, handlingar, mun, irisstencil), keyforms, studsande kedjor, ZIP, analys för läppsynk, inläsning och avvisning av VRM 0.x / 1.0, skinning, morphs och spring bones, samt det som VRM Add-on för Blender skriver (komprimering som nämns men inte används, `KHR_texture_transform`, samplers).

## Kända skillnader och begränsningar

- **MToon** efterliknas med RealityKits obelysta material (grundfärg, textur, alfaläge, dubbelsidighet). Det finns inget kantljus eller någon skuggräns.
- För **VRM** beräknas skinning och morphs på processorn och skrivs till ett LowLevelMesh varje bildruta. Använd ett Release-bygge för modeller med väldigt många hörn.
- **Ansiktsspårning** använder ARKit (TrueDepth) och finns därför inte på Mac eller Vision Pro. Utan läppmarkörer styrs munnens öppning bara av `jawOpen`.
- **visionOS**: en VRM är ungefär 0,36 m hög i fönstret.

## Licens

- Kod: Apache License 2.0, samma som LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Medföljande figurer: Apache-licensen gäller **inte**. Endast icke-kommersiell användning, med erkännande. Kujira och Kujira Q har CC BY-NC-SA 4.0, och för Pen ges inga rättigheter alls. Läs ”Licenser och varumärken” i appen innan du distribuerar den.
- Namnet och logotypen LivLiv omfattas inte av någon licens.
