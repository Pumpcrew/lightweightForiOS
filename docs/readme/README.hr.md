# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · **Hrvatski** · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Ovaj projekt prenosi [LivLiv Player](https://github.com/livliv-dev/player), reproduktor 2.5D likova za web (TypeScript/WebGL2), u **izvornu aplikaciju za iOS, macOS i visionOS**. Likovi se crtaju pomoću **Metala**, a VRM avatari pomoću učitavača glTF/VRM napisanog za ovaj projekt na **RealityKitu**.

## Zahtjevi

- iOS 18, macOS 15 ili visionOS 2 ili noviji (Xcode 16 ili noviji, alati Swift 6)
- Bez vanjskih ovisnosti. Logika aplikacije nalazi se u lokalnom Swift paketu (`Packages/LivLivKit`).

## Izgradnja

1. Otvorite `livlivIOSPlayer.xcodeproj` u Xcodeu.
2. U Signing & Capabilities odaberite svoj Team i po potrebi promijenite identifikator paketa.
3. Kao odredište odaberite iPhone ili iPad (uređaj ili simulator), My Mac ili Apple Vision Pro, a zatim pritisnite Run (⌘R).

`LivLivCore` se i u Debugu gradi s `-O` jer kostur u svakom kadru pomiče desetke tisuća vrhova (k01: oko 17 ms po kadru uz `-Onone`, oko 2 ms uz `-O`).

## Značajke

- **Likovi**: 21 priloženi lik
- **Uvezi**: odaberite mapu ili datoteku koju ste stavili u mapu Documents aplikacije. Aplikacija najprije provjeri može li je otvoriti, a zatim je učita. Ako ne može, upozorenje prikazuje razlog u tekstnom prikazu koji možete označiti i kopirati.
- Mapa Documents: na iPhoneu, iPadu i Vision Pro u Datoteke › Na mom iPhoneu › livlivIOSPlayer; na Macu pomoću „Otvori mapu Documents u Finderu” u Uvezi. „Odaberi s druge lokacije…” otvara mapu ili datoteku s drugog mjesta.
- Izrazi lica, radnje i drijemanje. Lik prati pokazivač, dijelovi koji se njišu odskaču na dodir, a štipanjem možete zumirati.
- **Sinkronizacija usana** iz mikrofona ili zvučne datoteke te **praćenje lica** na iPhoneu ili iPadu s TrueDepthom
- **Postavke**: pokret, razlučivost, praćenje lica te Licence otvorenog koda › „Licence i zaštitni znakovi”

## Podržani formati

- Mapa LivLiv modela (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), uključujući datoteke izvezene VRM Add-onom za Blender
- PNGTuber mapa: `closed.png`, `open.png` (neobavezno: `blink.png`, `blink-open.png`, `name.txt`)

Datoteka koja se ne može reproducirati (VRM bez mreže, kompresija Draco / Meshopt / KTX2, prevelike slike) odbija se uz navedeni razlog.

## Lokalizacija

- Tekstovi aplikacije postoje na 50 jezika, u katalozima nizova (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Razvojni jezik je engleski, a koriste ga i regionalne inačice engleskog.
- Dokument „Licence i zaštitni znakovi” prikazuje se na korejskom na korejskim uređajima, a drugdje na engleskom. Imena likova, navođenja autora i izvorni tekstovi licenci ne prevode se.
- Ovaj README dostupan je na istim jezicima (poveznice na vrhu). Prijevode još nisu pregledali izvorni govornici, pa su ispravci dobrodošli.

## Struktura projekta

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

## Izvornik → prijenos

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

## Testovi

```sh
cd Packages/LivLivKit
swift test
```

Provjereno na Linuxu: čitanje 21 priloženog lika i po 240 kadrova svakog (izrazi, radnje, usta, šablona šarenice), keyformovi, odskakanje lanaca, ZIP, analiza za sinkronizaciju usana, čitanje i odbijanje VRM 0.x / 1.0, skinning, morphovi i spring bones te ono što zapisuje VRM Add-on za Blender (kompresija navedena, ali ne korištena, `KHR_texture_transform`, uzorkivači).

## Poznate razlike i ograničenja

- **MToon** se približno prikazuje neosvijetljenim materijalom RealityKita (osnovna boja, tekstura, način alfa, dvostranost). Nema rubnog svjetla ni granice sjene.
- Kod **VRM-a** skinning i morphovi računaju se na CPU-u i u svakom kadru zapisuju u LowLevelMesh. Za modele s jako puno vrhova koristite Release izgradnju.
- **Praćenje lica** koristi ARKit (TrueDepth), pa nije dostupno na Macu ni na Vision Pro. Bez točaka usana otvorenost usta određuje se samo iz `jawOpen`.
- **visionOS**: VRM je u prozoru visok oko 0,36 m.

## Licenca

- Kôd: Apache License 2.0, kao i LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Priloženi likovi: Apache licenca na njih se **ne** primjenjuje. Samo nekomercijalna upotreba, uz navođenje autora. Kujira i Kujira Q su pod CC BY-NC-SA 4.0, a za Pen nisu dana nikakva prava. Prije distribucije pročitajte „Licence i zaštitni znakovi” u aplikaciji.
- Ime i logotip LivLiv nisu obuhvaćeni nijednom licencom.
