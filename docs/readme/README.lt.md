# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · **Lietuvių** · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Šis projektas perkelia [LivLiv Player](https://github.com/livliv-dev/player) – žiniatinklio 2.5D personažų grotuvą (TypeScript/WebGL2) – į **savąją iOS, macOS ir visionOS programą**. Personažai piešiami naudojant **Metal**, o VRM avatarai – šiam projektui ant **RealityKit** parašytu glTF/VRM įkėlikliu.

## Reikalavimai

- iOS 18, macOS 15 arba visionOS 2 ar naujesnė (Xcode 16 ar naujesnė, Swift 6 įrankiai)
- Jokių išorinių priklausomybių. Programos logika yra vietiniame Swift pakete (`Packages/LivLivKit`).

## Kompiliavimas

1. Atidarykite `livlivIOSPlayer.xcodeproj` programoje Xcode.
2. Skiltyje Signing & Capabilities pasirinkite savo Team ir, jei reikia, pakeiskite paketo identifikatorių.
3. Kaip paskirtį pasirinkite iPhone ar iPad (įrenginį ar simuliatorių), My Mac arba Apple Vision Pro ir paspauskite Run (⌘R).

`LivLivCore` net Debug režimu kompiliuojamas su `-O`, nes karkasas kiekviename kadre perkelia dešimtis tūkstančių viršūnių (k01: apie 17 ms kadrui su `-Onone`, apie 2 ms su `-O`).

## Funkcijos

- **Personažai**: 21 pridėtas personažas
- **Importuoti**: pasirinkite aplanką ar failą, kurį įdėjote į programos aplanką Documents. Programa pirmiausia patikrina, ar gali jį atidaryti, tada įkelia. Jei negali, įspėjimas parodo priežastį teksto rodinyje, kurį galima pažymėti ir nukopijuoti.
- Aplankas Documents: iPhone, iPad ir Vision Pro – „Failai“ › „Mano iPhone“ › livlivIOSPlayer; Mac – „Atidaryti aplanką Documents „Finder““ skiltyje „Importuoti“. „Pasirinkti iš kitos vietos…“ atidaro aplanką ar failą iš kitos vietos.
- Veido išraiškos, veiksmai ir snūduriavimas. Personažas seka žymeklį, siūbuojančios dalys palietus spyruokliuoja, o suspaudus pirštais galima didinti.
- **Lūpų sinchronizavimas** iš mikrofono ar garso failo ir **veido sekimas** iPhone ar iPad su TrueDepth
- **Nustatymai**: judesys, raiška, veido sekimas ir Atvirojo kodo licencijos › „Licencijos ir prekių ženklai“

## Palaikomi formatai

- LivLiv modelio aplankas (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), įskaitant failus, eksportuotus Blender skirtu VRM Add-on
- PNGTuber aplankas: `closed.png`, `open.png` (pasirinktinai: `blink.png`, `blink-open.png`, `name.txt`)

Failas, kurio negalima atkurti (VRM be tinklelio, Draco / Meshopt / KTX2 glaudinimas, per dideli vaizdai), atmetamas nurodant priežastį.

## Lokalizacija

- Programos tekstai yra 50 kalbų, eilučių kataloguose (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Kūrimo kalba – anglų, ją naudoja ir regioniniai anglų kalbos variantai.
- Dokumentas „Licencijos ir prekių ženklai“ korėjiečių kalbos įrenginiuose rodomas korėjiečių, kitur – anglų kalba. Personažų vardai, autorystės nuorodos ir originalūs licencijų tekstai neverčiami.
- Šis README pateikiamas tomis pačiomis kalbomis (nuorodos viršuje). Vertimų dar nepatikrino gimtakalbiai, todėl pataisymai laukiami.

## Projekto struktūra

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

## Originalas → perkėlimas

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

## Testai

```sh
cd Packages/LivLivKit
swift test
```

Patikrinta Linux: 21 pridėto personažo nuskaitymas ir po 240 kiekvieno kadrų (išraiškos, veiksmai, burna, rainelės trafaretas), keyforms, grandinių spyruokliavimas, ZIP, lūpų sinchronizavimo analizė, VRM 0.x / 1.0 nuskaitymas ir atmetimas, skinning, morph’ai ir spring bones, taip pat tai, ką rašo Blender skirtas VRM Add-on (nurodytas, bet nenaudojamas glaudinimas, `KHR_texture_transform`, sampler’iai).

## Žinomi skirtumai ir apribojimai

- **MToon** apytiksliai atkuriamas RealityKit neapšviestąja medžiaga (pagrindinė spalva, tekstūra, alfa režimas, dvipusiškumas). Nėra kontūro šviesos ir šešėlio ribos.
- **VRM** skinning ir morph’ai skaičiuojami CPU ir kiekviename kadre įrašomi į LowLevelMesh. Modeliams su labai daug viršūnių naudokite Release kompiliavimą.
- **Veido sekimas** naudoja ARKit (TrueDepth), todėl Mac ir Vision Pro neprieinamas. Neturint lūpų taškų, burnos atvėrimas nustatomas tik iš `jawOpen`.
- **visionOS**: VRM lange yra apie 0,36 m aukščio.

## Licencija

- Kodas: Apache License 2.0, kaip ir LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Pridėti personažai: Apache licencija jiems **netaikoma**. Tik nekomercinis naudojimas, nurodant autorių. Kujira ir Kujira Q – CC BY-NC-SA 4.0, o Pen nesuteikiama jokių teisių. Prieš platindami perskaitykite programoje esantį „Licencijos ir prekių ženklai“.
- LivLiv pavadinimui ir logotipui netaikoma jokia licencija.
