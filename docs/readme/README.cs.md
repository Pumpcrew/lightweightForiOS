# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · **Čeština** · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Tento projekt převádí [LivLiv Player](https://github.com/livliv-dev/player), přehrávač 2.5D postav pro web (TypeScript/WebGL2), do **nativní aplikace pro iOS, macOS a visionOS**. Postavy se kreslí přes **Metal** a avatary VRM přes zavaděč glTF/VRM napsaný pro tento projekt nad **RealityKit**.

## Požadavky

- iOS 18, macOS 15 nebo visionOS 2 či novější (Xcode 16 či novější, nástroje Swift 6)
- Žádné externí závislosti. Logika aplikace je v místním balíčku Swift (`Packages/LivLivKit`).

## Sestavení

1. Otevřete `livlivIOSPlayer.xcodeproj` v Xcode.
2. V Signing & Capabilities vyberte svůj Team a v případě potřeby změňte identifikátor balíčku.
3. Jako cíl vyberte iPhone nebo iPad (zařízení či simulátor), My Mac nebo Apple Vision Pro a stiskněte Run (⌘R).

`LivLivCore` se i v Debug sestavuje s `-O`, protože rig v každém snímku posouvá desítky tisíc vrcholů (k01: asi 17 ms na snímek s `-Onone`, asi 2 ms s `-O`).

## Funkce

- **Postavy**: 21 přiložených postav
- **Importovat**: vyberte složku nebo soubor, které jste vložili do složky Documents aplikace. Aplikace nejdřív ověří, že je umí otevřít, a pak je načte. Pokud ne, upozornění ukáže důvod v textovém zobrazení, které lze označit a zkopírovat.
- Složka Documents: na iPhonu, iPadu a Vision Pro v Soubory › Na mém iPhonu › livlivIOSPlayer; na Macu přes „Otevřít složku Documents ve Finderu“ v Importovat. „Vybrat z jiného umístění…“ otevře složku nebo soubor odjinud.
- Výrazy, akce a dřímání. Postava sleduje ukazatel, houpající se části po klepnutí pruží a sevřením prstů lze přiblížit.
- **Synchronizace rtů** z mikrofonu nebo zvukového souboru a **sledování obličeje** na iPhonu nebo iPadu s TrueDepth
- **Nastavení**: pohyb, rozlišení, sledování obličeje a Licence open source › „Licence a ochranné známky“

## Podporované formáty

- Složka modelu LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), včetně souborů exportovaných VRM Add-onem pro Blender
- Složka PNGTuber: `closed.png`, `open.png` (volitelně: `blink.png`, `blink-open.png`, `name.txt`)

Soubor, který nelze přehrát (VRM bez sítě, komprese Draco / Meshopt / KTX2, příliš velké obrázky), se odmítne s uvedením důvodu.

## Lokalizace

- Texty aplikace jsou v 50 jazycích v katalozích řetězců (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Vývojovým jazykem je angličtina, kterou používají i regionální varianty angličtiny.
- Dokument „Licence a ochranné známky“ se na korejských zařízeních zobrazuje korejsky, jinde anglicky. Jména postav, uvedení autorů a původní texty licencí se nepřekládají.
- Tento README je ve stejných jazycích (odkazy nahoře). Překlady zatím nezkontrolovali rodilí mluvčí, opravy jsou proto vítány.

## Struktura projektu

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

Ověřeno na Linuxu: načtení 21 přiložených postav a 240 snímků každé z nich (výrazy, akce, ústa, stencil duhovky), keyformy, pružení řetězů, ZIP, analýza pro synchronizaci rtů, načítání a odmítání VRM 0.x / 1.0, skinning, morphy a spring bones a to, co zapisuje VRM Add-on pro Blender (uvedená, ale nepoužitá komprese, `KHR_texture_transform`, samplery).

## Známé rozdíly a omezení

- **MToon** se napodobuje neosvětleným materiálem RealityKit (základní barva, textura, režim alfa, oboustrannost). Chybí obrysové světlo a hranice stínu.
- U **VRM** se skinning a morphy počítají na CPU a v každém snímku se zapisují do LowLevelMesh. Pro modely s velmi mnoha vrcholy použijte sestavení Release.
- **Sledování obličeje** používá ARKit (TrueDepth), takže na Macu ani na Vision Pro není k dispozici. Bez bodů rtů se otevření úst určuje jen z `jawOpen`.
- **visionOS**: VRM je v okně vysoký asi 0,36 m.

## Licence

- Kód: Apache License 2.0, stejně jako LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Přiložené postavy: licence Apache se na ně **nevztahuje**. Pouze nekomerční použití s uvedením autora. Kujira a Kujira Q jsou pod CC BY-NC-SA 4.0 a k Pen nejsou udělena žádná práva. Před šířením si v aplikaci přečtěte „Licence a ochranné známky“.
- Název a logo LivLiv nepokrývá žádná licence.
