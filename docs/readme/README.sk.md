# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · **Slovenčina** · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Tento projekt prevádza [LivLiv Player](https://github.com/livliv-dev/player), prehrávač 2.5D postáv pre web (TypeScript/WebGL2), do **natívnej aplikácie pre iOS, macOS a visionOS**. Postavy sa kreslia cez **Metal** a avatary VRM cez zavádzač glTF/VRM napísaný pre tento projekt nad **RealityKit**.

## Požiadavky

- iOS 18, macOS 15 alebo visionOS 2 či novší (Xcode 16 či novší, nástroje Swift 6)
- Žiadne externé závislosti. Logika aplikácie je v lokálnom balíku Swift (`Packages/LivLivKit`).

## Zostavenie

1. Otvorte `livlivIOSPlayer.xcodeproj` v Xcode.
2. V Signing & Capabilities vyberte svoj Team a v prípade potreby zmeňte identifikátor balíka.
3. Ako cieľ vyberte iPhone alebo iPad (zariadenie či simulátor), My Mac alebo Apple Vision Pro a stlačte Run (⌘R).

`LivLivCore` sa aj v Debug zostavuje s `-O`, pretože rig v každej snímke posúva desiatky tisíc vrcholov (k01: asi 17 ms na snímku s `-Onone`, asi 2 ms s `-O`).

## Funkcie

- **Postavy**: 21 priložených postáv
- **Importovať**: vyberte priečinok alebo súbor, ktorý ste vložili do priečinka Documents aplikácie. Aplikácia najprv overí, že ho vie otvoriť, a potom ho načíta. Ak nie, upozornenie ukáže dôvod v textovom zobrazení, ktoré možno označiť a skopírovať.
- Priečinok Documents: na iPhone, iPade a Vision Pro v Súbory › Na mojom iPhone › livlivIOSPlayer; na Macu cez „Otvoriť priečinok Documents vo Finderi“ v Importovať. „Vybrať z iného umiestnenia…“ otvorí priečinok alebo súbor odinakiaľ.
- Výrazy, akcie a driemanie. Postava sleduje ukazovateľ, hojdajúce sa časti po klepnutí pružia a stiahnutím prstov možno priblížiť.
- **Synchronizácia pier** z mikrofónu alebo zvukového súboru a **sledovanie tváre** na iPhone alebo iPade s TrueDepth
- **Nastavenia**: pohyb, rozlíšenie, sledovanie tváre a Licencie open source › „Licencie a ochranné známky“

## Podporované formáty

- Priečinok modelu LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0) vrátane súborov exportovaných VRM Add-onom pre Blender
- Priečinok PNGTuber: `closed.png`, `open.png` (voliteľne: `blink.png`, `blink-open.png`, `name.txt`)

Súbor, ktorý sa nedá prehrať (VRM bez siete, kompresia Draco / Meshopt / KTX2, príliš veľké obrázky), sa odmietne s uvedením dôvodu.

## Lokalizácia

- Texty aplikácie sú v 50 jazykoch v katalógoch reťazcov (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Vývojovým jazykom je angličtina, ktorú používajú aj regionálne varianty angličtiny.
- Dokument „Licencie a ochranné známky“ sa na kórejských zariadeniach zobrazuje po kórejsky, inde po anglicky. Mená postáv, uvedenie autorov a pôvodné texty licencií sa neprekladajú.
- Tento README je v rovnakých jazykoch (odkazy hore). Preklady zatiaľ neskontrolovali rodení hovoriaci, preto sú opravy vítané.

## Štruktúra projektu

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

## Originál → port

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

## Testy

```sh
cd Packages/LivLivKit
swift test
```

Overené na Linuxe: načítanie 21 priložených postáv a 240 snímok každej z nich (výrazy, akcie, ústa, stencil dúhovky), keyformy, pruženie reťazí, ZIP, analýza pre synchronizáciu pier, načítanie a odmietanie VRM 0.x / 1.0, skinning, morphy a spring bones a to, čo zapisuje VRM Add-on pre Blender (uvedená, ale nepoužitá kompresia, `KHR_texture_transform`, samplery).

## Známe rozdiely a obmedzenia

- **MToon** sa napodobňuje neosvetleným materiálom RealityKit (základná farba, textúra, režim alfa, obojstrannosť). Chýba obrysové svetlo aj hranica tieňa.
- Pri **VRM** sa skinning a morphy počítajú na CPU a v každej snímke sa zapisujú do LowLevelMesh. Pre modely s veľmi mnohými vrcholmi použite zostavenie Release.
- **Sledovanie tváre** používa ARKit (TrueDepth), takže na Macu ani na Vision Pro nie je k dispozícii. Bez bodov pier sa otvorenie úst určuje len z `jawOpen`.
- **visionOS**: VRM je v okne vysoký asi 0,36 m.

## Licencia

- Kód: Apache License 2.0, rovnako ako LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Priložené postavy: licencia Apache sa na ne **nevzťahuje**. Iba nekomerčné použitie s uvedením autora. Kujira a Kujira Q sú pod CC BY-NC-SA 4.0 a k Pen nie sú udelené žiadne práva. Pred šírením si v aplikácii prečítajte „Licencie a ochranné známky“.
- Názov a logo LivLiv nepokrýva žiadna licencia.
