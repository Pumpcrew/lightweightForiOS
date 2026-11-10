# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · **Suomi** · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Tämä projekti siirtää [LivLiv Playerin](https://github.com/livliv-dev/player), verkon 2.5D-hahmosoittimen (TypeScript/WebGL2), **iOS:n, macOS:n ja visionOS:n natiiviksi apiksi**. Hahmot piirretään **Metalilla** ja VRM-avatarit tätä projektia varten **RealityKitin** päälle kirjoitetulla glTF/VRM-lataimella.

## Vaatimukset

- iOS 18, macOS 15 tai visionOS 2 tai uudempi (Xcode 16 tai uudempi, Swift 6 -työkaluketju)
- Ei ulkoisia riippuvuuksia. Apin logiikka on paikallisessa Swift-paketissa (`Packages/LivLivKit`).

## Kääntäminen

1. Avaa `livlivIOSPlayer.xcodeproj` Xcodessa.
2. Valitse Signing & Capabilities -kohdasta oma Teamisi ja vaihda tarvittaessa paketin tunniste.
3. Valitse kohteeksi iPhone tai iPad (laite tai simulaattori), My Mac tai Apple Vision Pro ja paina Run (⌘R).

`LivLivCore` käännetään `-O`-asetuksella myös Debugissa, koska rigi liikuttaa kymmeniätuhansia verteksejä joka kuvassa (k01: noin 17 ms kuvaa kohden `-Onone`-asetuksella, noin 2 ms `-O`-asetuksella).

## Ominaisuudet

- **Hahmot**: 21 mukana tulevaa hahmoa
- **Tuo**: valitse kansio tai tiedosto, jonka olet laittanut apin Documents-kansioon. Appi tarkistaa ensin, että se voi avata sen, ja lataa sen sitten. Jos ei voi, ilmoitus näyttää syyn tekstinäkymässä, jonka voi valita ja kopioida.
- Documents-kansio: iPhonessa, iPadissa ja Vision Prossa Tiedostot › Omassa iPhonessa › livlivIOSPlayer; Macissa Tuo-kohdan ”Avaa Documents-kansio Finderissa”. ”Valitse toisesta sijainnista…” avaa kansion tai tiedoston muualta.
- Ilmeet, toiminnot ja torkkuminen. Hahmo seuraa osoitinta, heiluvat osat joustavat napautettaessa, ja voit zoomata nipistämällä.
- **Huulisynkronointi** mikrofonista tai äänitiedostosta ja **kasvojen seuranta** iPhonessa tai iPadissa, jossa on TrueDepth
- **Asetukset**: liike, tarkkuus, kasvojen seuranta sekä Avoimen lähdekoodin lisenssit › ”Lisenssit ja tavaramerkit”

## Tuetut muodot

- LivLiv-mallikansio (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), myös Blenderin VRM Add-onilla viedyt tiedostot
- PNGTuber-kansio: `closed.png`, `open.png` (valinnaiset: `blink.png`, `blink-open.png`, `name.txt`)

Tiedosto, jota ei voi toistaa (VRM ilman meshiä, Draco-/Meshopt-/KTX2-pakkaus, liian suuret kuvat), hylätään syyn kera.

## Lokalisointi

- Apin tekstit ovat 50 kielellä String Catalogeissa (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Kehityskieli on englanti, ja englannin alueelliset muunnelmat käyttävät sitä.
- ”Lisenssit ja tavaramerkit”-asiakirja näkyy korealaisissa laitteissa koreaksi ja muualla englanniksi. Hahmojen nimiä, tekijätietoja ja lisenssien alkuperäisiä tekstejä ei käännetä.
- Tämä README on saatavilla samoilla kielillä (linkit ylhäällä). Käännöksiä ei ole vielä tarkistettu äidinkielisten puhujien toimesta, joten korjaukset ovat tervetulleita.

## Projektin rakenne

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

## Alkuperäinen → siirretty

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

## Testit

```sh
cd Packages/LivLivKit
swift test
```

Tarkistettu Linuxissa: 21 mukana tulevan hahmon lukeminen ja jokaisesta 240 kuvaa (ilmeet, toiminnot, suu, iiriksen stencil), keyformit, ketjujen jousto, ZIP, huulisynkronoinnin analyysi, VRM 0.x / 1.0 -tiedostojen lukeminen ja hylkääminen, skinning, morphit ja spring bonet sekä se, mitä Blenderin VRM Add-on kirjoittaa (mainittu mutta käyttämätön pakkaus, `KHR_texture_transform`, samplerit).

## Tunnetut erot ja rajoitukset

- **MToonia** jäljitellään RealityKitin valaisemattomalla materiaalilla (perusväri, tekstuuri, alfatila, kaksipuolisuus). Reunavaloa ja varjon rajaa ei ole.
- **VRM**:n skinning ja morphit lasketaan suorittimella ja kirjoitetaan LowLevelMeshiin joka kuvassa. Käytä Release-käännöstä malleille, joissa on hyvin paljon verteksejä.
- **Kasvojen seuranta** käyttää ARKitia (TrueDepth), joten se ei ole käytettävissä Macissa eikä Vision Prossa. Koska huulten maamerkkejä ei ole, suun avautuminen tulee vain `jawOpen`-arvosta.
- **visionOS**: VRM on ikkunassa noin 0,36 m korkea.

## Lisenssi

- Koodi: Apache License 2.0, sama kuin LivLiv Playerissa (`livlivIOSPlayer/Resources/Legal/`).
- Mukana tulevat hahmot: Apache-lisenssi **ei** koske niitä. Vain ei-kaupalliseen käyttöön, tekijä mainiten. Kujira ja Kujira Q ovat CC BY-NC-SA 4.0 -lisenssillä, eikä Penille anneta mitään oikeuksia. Lue apin ”Lisenssit ja tavaramerkit” ennen jakelua.
- Nimi ja logo LivLiv eivät kuulu minkään lisenssin piiriin.
