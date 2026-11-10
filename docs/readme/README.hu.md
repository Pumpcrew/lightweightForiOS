# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · **Magyar** · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Ez a projekt a [LivLiv Player](https://github.com/livliv-dev/player) nevű webes 2.5D karakterlejátszót (TypeScript/WebGL2) **natív iOS-, macOS- és visionOS-appá** alakítja. A karaktereket a **Metal** rajzolja, a VRM-avatarokat pedig egy, a projekthez a **RealityKitre** írt glTF/VRM-betöltő.

## Követelmények

- iOS 18, macOS 15 vagy visionOS 2 vagy újabb (Xcode 16 vagy újabb, Swift 6 eszközkészlet)
- Nincsenek külső függőségek. Az app logikája egy helyi Swift-csomagban van (`Packages/LivLivKit`).

## Fordítás

1. Nyissa meg a `livlivIOSPlayer.xcodeproj` fájlt az Xcode-ban.
2. A Signing & Capabilities alatt válassza ki a saját Teamjét, és ha kell, módosítsa a csomagazonosítót.
3. Célként válasszon iPhone-t vagy iPadet (eszközt vagy szimulátort), a My Macet vagy az Apple Vision Prót, majd nyomja meg a Run (⌘R) gombot.

A `LivLivCore` Debugban is `-O` beállítással fordul, mert a rig képkockánként több tízezer csúcsot mozgat (k01: `-Onone` mellett kb. 17 ms, `-O` mellett kb. 2 ms képkockánként).

## Funkciók

- **Karakterek**: 21 mellékelt karakter
- **Importálás**: válasszon egy mappát vagy fájlt, amelyet az app Documents mappájába tett. Az app először ellenőrzi, hogy meg tudja-e nyitni, majd betölti. Ha nem, egy figyelmeztetés mutatja az okot egy kijelölhető és másolható szövegnézetben.
- Documents mappa: iPhone-on, iPaden és Vision Prón a Fájlok › iPhone-omon › livlivIOSPlayer helyen; Macen a(z) Importálás „Documents mappa megnyitása a Finderben” pontjával. A „Választás más helyről…” máshol lévő mappát vagy fájlt nyit meg.
- Arckifejezések, mozdulatok és szundítás. A karakter követi a mutatót, a lengő részek koppintásra rugóznak, és csippentéssel nagyítani lehet.
- **Szájszinkron** a mikrofonról vagy hangfájlból, és **arckövetés** TrueDepth-kamerás iPhone-on vagy iPaden
- **Beállítások**: mozgás, felbontás, arckövetés, valamint Nyílt forráskódú licencek › „Licencek és védjegyek”

## Támogatott formátumok

- LivLiv-modellmappa (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), a Blenderhez készült VRM Add-onnal exportált fájlokat is beleértve
- PNGTuber-mappa: `closed.png`, `open.png` (opcionális: `blink.png`, `blink-open.png`, `name.txt`)

A le nem játszható fájlt (háló nélküli VRM, Draco / Meshopt / KTX2 tömörítés, túl nagy képek) az app az ok megadásával elutasítja.

## Honosítás

- Az app szövegei 50 nyelven érhetők el, String Catalogokban (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). A fejlesztési nyelv az angol, ezt használják az angol regionális változatai is.
- A(z) „Licencek és védjegyek” dokumentum koreai nyelvű eszközökön koreaiul, máshol angolul jelenik meg. A karakterek neve, a feltüntetett alkotók és a licencek eredeti szövege nincs lefordítva.
- Ez a README ugyanezeken a nyelveken érhető el (hivatkozások fent). A fordításokat anyanyelvi beszélők még nem ellenőrizték, ezért a javításokat szívesen fogadjuk.

## A projekt felépítése

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

## Eredeti → port

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

## Tesztek

```sh
cd Packages/LivLivKit
swift test
```

Linuxon ellenőrizve: a 21 mellékelt karakter beolvasása és mindegyikből 240 képkocka (arckifejezések, mozdulatok, száj, írisz-stencil), keyformok, a láncok rugózása, ZIP, a szájszinkron elemzése, VRM 0.x / 1.0 beolvasása és elutasítása, skinning, morphok és spring bone-ok, valamint amit a Blenderhez készült VRM Add-on ír (megnevezett, de nem használt tömörítés, `KHR_texture_transform`, samplerek).

## Ismert eltérések és korlátok

- Az **MToont** a RealityKit megvilágítás nélküli anyaga közelíti (alapszín, textúra, alfa mód, kétoldalasság). Nincs peremfény és árnyékhatár.
- A **VRM** skinningje és morphjai a CPU-n számolódnak, és képkockánként egy LowLevelMeshbe íródnak. Nagyon sok csúcsú modellekhez Release-fordítást ajánlunk.
- Az **arckövetés** ARKitet (TrueDepth) használ, így Macen és Vision Prón nem érhető el. Ajakpontok hiányában a száj nyitását csak a `jawOpen` adja.
- **visionOS**: a VRM nagyjából 0,36 m magas az ablakban.

## Licenc

- Kód: Apache License 2.0, akárcsak a LivLiv Playernél (`livlivIOSPlayer/Resources/Legal/`).
- Mellékelt karakterek: az Apache-licenc rájuk **nem** vonatkozik. Csak nem kereskedelmi használat, az alkotó feltüntetésével. A Kujira és a Kujira Q CC BY-NC-SA 4.0 alatt áll, a Penhez pedig semmilyen jog nem jár. Terjesztés előtt olvassa el az appban a(z) „Licencek és védjegyek” dokumentumot.
- A LivLiv név és logó egyik licencnek sem része.
