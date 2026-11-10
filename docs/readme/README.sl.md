# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · **Slovenščina** · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Ta projekt prenaša [LivLiv Player](https://github.com/livliv-dev/player), predvajalnik 2.5D likov za splet (TypeScript/WebGL2), v **izvorno aplikacijo za iOS, macOS in visionOS**. Liki se rišejo z **Metal**, avatarji VRM pa z nalagalnikom glTF/VRM, napisanim za ta projekt na **RealityKit**.

## Zahteve

- iOS 18, macOS 15 ali visionOS 2 ali novejši (Xcode 16 ali novejši, orodja Swift 6)
- Brez zunanjih odvisnosti. Logika aplikacije je v lokalnem paketu Swift (`Packages/LivLivKit`).

## Gradnja

1. V Xcode odprite `livlivIOSPlayer.xcodeproj`.
2. V Signing & Capabilities izberite svoj Team in po potrebi spremenite identifikator paketa.
3. Za cilj izberite iPhone ali iPad (napravo ali simulator), My Mac ali Apple Vision Pro in pritisnite Run (⌘R).

`LivLivCore` se tudi v Debug gradi z `-O`, ker ogrodje v vsaki sličici premakne več deset tisoč oglišč (k01: približno 17 ms na sličico z `-Onone`, približno 2 ms z `-O`).

## Funkcije

- **Liki**: 21 priloženih likov
- **Uvozi**: izberite mapo ali datoteko, ki ste jo dali v mapo Documents aplikacije. Aplikacija najprej preveri, ali jo lahko odpre, nato jo naloži. Če je ne more, opozorilo prikaže razlog v besedilnem pogledu, ki ga lahko izberete in kopirate.
- Mapa Documents: v iPhonu, iPadu in Vision Pro pod Datoteke › V mojem iPhonu › livlivIOSPlayer; v Macu z »Odpri mapo Documents v Finderju« v Uvozi. »Izberi z drugega mesta …« odpre mapo ali datoteko drugje.
- Izrazi, dejanja in dremež. Lik sledi kazalcu, nihajoči deli ob dotiku zanihajo, s ščipom pa lahko povečate.
- **Sinhronizacija ustnic** iz mikrofona ali zvočne datoteke ter **sledenje obrazu** v iPhonu ali iPadu s TrueDepth
- **Nastavitve**: gibanje, ločljivost, sledenje obrazu in Odprtokodne licence › »Licence in blagovne znamke«

## Podprte oblike

- Mapa modela LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), tudi datoteke, izvožene z VRM Add-on za Blender
- Mapa PNGTuber: `closed.png`, `open.png` (neobvezno: `blink.png`, `blink-open.png`, `name.txt`)

Datoteka, ki je ni mogoče predvajati (VRM brez mreže, stiskanje Draco / Meshopt / KTX2, prevelike slike), je zavrnjena z navedbo razloga.

## Lokalizacija

- Besedila aplikacije so v 50 jezikih, v katalogih nizov (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Razvojni jezik je angleščina, ki jo uporabljajo tudi regionalne različice angleščine.
- Dokument »Licence in blagovne znamke« je v korejskih napravah v korejščini, drugje v angleščini. Imena likov, navedbe avtorjev in izvirna besedila licenc niso prevedeni.
- Ta README je v istih jezikih (povezave na vrhu). Prevodov še niso pregledali rojeni govorci, zato so popravki dobrodošli.

## Zgradba projekta

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

## Izvirnik → prenos

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

## Preizkusi

```sh
cd Packages/LivLivKit
swift test
```

Preverjeno v Linuxu: branje 21 priloženih likov in po 240 sličic vsakega (izrazi, dejanja, usta, šablona šarenice), keyformi, nihanje verig, ZIP, analiza za sinhronizacijo ustnic, branje in zavračanje VRM 0.x / 1.0, skinning, morphi in spring bones ter to, kar zapiše VRM Add-on za Blender (navedeno, a neuporabljeno stiskanje, `KHR_texture_transform`, vzorčevalniki).

## Znane razlike in omejitve

- **MToon** je približan z neosvetljenim materialom RealityKit (osnovna barva, tekstura, način alfa, dvostranskost). Robne svetlobe in meje sence ni.
- Pri **VRM** se skinning in morphi računajo na CPE in se v vsaki sličici zapišejo v LowLevelMesh. Za modele z zelo veliko oglišči uporabite gradnjo Release.
- **Sledenje obrazu** uporablja ARKit (TrueDepth), zato v Macu in Vision Pro ni na voljo. Brez točk ustnic se odprtost ust določa samo iz `jawOpen`.
- **visionOS**: VRM je v oknu visok približno 0,36 m.

## Licenca

- Koda: Apache License 2.0, enako kot LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Priloženi liki: licenca Apache zanje **ne** velja. Samo za nekomercialno uporabo z navedbo avtorja. Kujira in Kujira Q sta pod CC BY-NC-SA 4.0, za Pen pa niso podeljene nobene pravice. Pred razširjanjem v aplikaciji preberite »Licence in blagovne znamke«.
- Ime in logotip LivLiv nista zajeta v nobeni licenci.
