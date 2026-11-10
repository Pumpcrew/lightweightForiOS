# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · **Română** · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Acest proiect portează [LivLiv Player](https://github.com/livliv-dev/player), un player de personaje 2.5D pentru web (TypeScript/WebGL2), într-o **aplicație nativă pentru iOS, macOS și visionOS**. Personajele sunt desenate cu **Metal**, iar avatarurile VRM cu un încărcător glTF/VRM scris pentru acest proiect peste **RealityKit**.

## Cerințe

- iOS 18, macOS 15 sau visionOS 2 ori mai nou (Xcode 16 ori mai nou, instrumente Swift 6)
- Fără dependențe externe. Logica aplicației se află într-un pachet Swift local (`Packages/LivLivKit`).

## Compilare

1. Deschideți `livlivIOSPlayer.xcodeproj` în Xcode.
2. În Signing & Capabilities, alegeți propriul Team și, dacă e nevoie, schimbați identificatorul pachetului.
3. Alegeți ca destinație un iPhone sau iPad (dispozitiv sau simulator), My Mac sau Apple Vision Pro, apoi apăsați Run (⌘R).

`LivLivCore` este compilat cu `-O` chiar și în Debug, deoarece rigul mută zeci de mii de vârfuri la fiecare cadru (k01: aproximativ 17 ms pe cadru cu `-Onone`, aproximativ 2 ms cu `-O`).

## Funcții

- **Personaje**: 21 de personaje incluse
- **Importă**: alegeți un dosar sau un fișier pus în dosarul Documents al aplicației. Aplicația verifică întâi că îl poate deschide, apoi îl încarcă. Dacă nu poate, o alertă arată motivul într-o vizualizare de text pe care o puteți selecta și copia.
- Dosarul Documents: pe iPhone, iPad și Vision Pro, în Fișiere › Pe iPhone-ul meu › livlivIOSPlayer; pe Mac, cu „Deschide dosarul Documents în Finder” din Importă. „Alege din altă locație…” deschide un dosar sau un fișier din altă parte.
- Expresii, acțiuni și ațipire. Personajul urmărește cursorul, părțile care se leagănă sar când le atingeți și puteți ciupi pentru a mări.
- **Sincronizarea buzelor** de la microfon sau dintr-un fișier audio și **urmărirea feței** pe un iPhone sau iPad cu TrueDepth
- **Configurări**: mișcare, rezoluție, urmărirea feței și Licențe open source › „Licențe și mărci comerciale”

## Formate acceptate

- Dosar de model LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), inclusiv fișiere exportate cu VRM Add-on pentru Blender
- Dosar PNGTuber: `closed.png`, `open.png` (opțional: `blink.png`, `blink-open.png`, `name.txt`)

Un fișier care nu poate fi redat (un VRM fără plasă, compresie Draco / Meshopt / KTX2, imagini prea mari) este refuzat cu motivul.

## Localizare

- Textele aplicației sunt în 50 de limbi, în cataloage de șiruri (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Limba de dezvoltare este engleza, folosită și de variantele regionale ale englezei.
- Documentul „Licențe și mărci comerciale” apare în coreeană pe dispozitivele în coreeană și în engleză în rest. Numele personajelor, mențiunile autorilor și textele originale ale licențelor nu se traduc.
- Acest README este disponibil în aceleași limbi (linkuri sus). Traducerile nu au fost încă verificate de vorbitori nativi, așa că sunt binevenite corecturile.

## Structura proiectului

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

## Original → port

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

## Teste

```sh
cd Packages/LivLivKit
swift test
```

Verificat pe Linux: citirea celor 21 de personaje incluse și câte 240 de cadre din fiecare (expresii, acțiuni, gură, stencil pentru iris), keyforms, săltarea lanțurilor, ZIP, analiza pentru sincronizarea buzelor, citirea și refuzarea VRM 0.x / 1.0, skinning, morphs și spring bones, plus ce scrie VRM Add-on pentru Blender (compresie menționată, dar nefolosită, `KHR_texture_transform`, samplere).

## Diferențe și limite cunoscute

- **MToon** este aproximat cu materialul neiluminat din RealityKit (culoare de bază, textură, mod alfa, față dublă). Nu există lumină de contur sau limită a umbrei.
- La **VRM**, skinning-ul și morph-urile se calculează pe CPU și se scriu într-un LowLevelMesh la fiecare cadru. Pentru modele cu foarte multe vârfuri folosiți o compilare Release.
- **Urmărirea feței** folosește ARKit (TrueDepth), deci nu este disponibilă pe Mac sau Vision Pro. Fără repere pentru buze, deschiderea gurii vine doar din `jawOpen`.
- **visionOS**: un VRM are aproximativ 0,36 m înălțime în fereastră.

## Licență

- Cod: Apache License 2.0, la fel ca LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Personaje incluse: licența Apache **nu** se aplică. Doar utilizare necomercială, cu atribuire. Kujira și Kujira Q sunt CC BY-NC-SA 4.0, iar pentru Pen nu se acordă niciun drept. Citiți „Licențe și mărci comerciale” în aplicație înainte de a o distribui.
- Numele și logoul LivLiv nu sunt acoperite de nicio licență.
