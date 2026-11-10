# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · **Bahasa Melayu**

Projek ini mengalihkan [LivLiv Player](https://github.com/livliv-dev/player), pemain watak 2.5D untuk web (TypeScript/WebGL2), kepada **app asli untuk iOS, macOS dan visionOS**. Watak dilukis dengan **Metal**, dan avatar VRM dengan pemuat glTF/VRM yang ditulis untuk projek ini di atas **RealityKit**.

## Keperluan

- iOS 18, macOS 15 atau visionOS 2 atau lebih baharu (Xcode 16 atau lebih baharu, rantaian alat Swift 6)
- Tiada kebergantungan luar. Logik app berada dalam pakej Swift setempat (`Packages/LivLivKit`).

## Bina

1. Buka `livlivIOSPlayer.xcodeproj` dalam Xcode.
2. Dalam Signing & Capabilities, pilih Team anda sendiri dan tukar pengecam himpunan jika perlu.
3. Pilih iPhone atau iPad (peranti atau simulator), My Mac atau Apple Vision Pro sebagai destinasi, kemudian tekan Run (⌘R).

`LivLivCore` dibina dengan `-O` walaupun dalam Debug, kerana rig menggerakkan puluhan ribu bucu setiap bingkai (k01: kira-kira 17 ms sebingkai dengan `-Onone`, kira-kira 2 ms dengan `-O`).

## Ciri

- **Watak**: 21 watak yang disertakan
- **Import**: pilih folder atau fail yang anda letakkan dalam folder Documents app. App menyemak dahulu bahawa ia boleh membukanya, kemudian memuatkannya. Jika tidak boleh, amaran menunjukkan sebabnya dalam paparan teks yang boleh dipilih dan disalin.
- Folder Documents: pada iPhone, iPad dan Vision Pro dalam Fail › Pada iPhone Saya › livlivIOSPlayer; pada Mac melalui “Buka Folder Documents dalam Finder” dalam Import. “Pilih dari Lokasi Lain…” membuka folder atau fail dari tempat lain.
- Mimik muka, aksi dan terlelap. Watak mengikut penuding, bahagian yang berayun melantun apabila diketik, dan anda boleh mencubit untuk zum.
- **Penyegerakan bibir** daripada mikrofon atau fail audio, dan **penjejakan muka** pada iPhone atau iPad dengan TrueDepth
- **Seting**: pergerakan, resolusi, penjejakan muka, dan Lesen Sumber Terbuka › “Lesen dan Tanda Dagangan”

## Format yang disokong

- Folder model LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), termasuk fail yang dieksport dengan VRM Add-on untuk Blender
- Folder PNGTuber: `closed.png`, `open.png` (pilihan: `blink.png`, `blink-open.png`, `name.txt`)

Fail yang tidak boleh dimainkan (VRM tanpa jejaring, pemampatan Draco / Meshopt / KTX2, imej terlalu besar) ditolak berserta sebabnya.

## Penyetempatan

- Teks app tersedia dalam 50 bahasa, dalam String Catalog (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Bahasa pembangunan ialah bahasa Inggeris, yang turut digunakan oleh varian serantau bahasa Inggeris.
- Dokumen “Lesen dan Tanda Dagangan” dipaparkan dalam bahasa Korea pada peranti berbahasa Korea dan dalam bahasa Inggeris di tempat lain. Nama watak, kredit dan teks asal lesen tidak diterjemahkan.
- README ini tersedia dalam bahasa yang sama (pautan di atas). Terjemahan belum disemak oleh penutur asli, jadi pembetulan amat dialu-alukan.

## Struktur projek

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

## Asal → alihan

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

## Ujian

```sh
cd Packages/LivLivKit
swift test
```

Disemak pada Linux: membaca 21 watak yang disertakan dan memainkan 240 bingkai setiap satu (mimik, aksi, mulut, stensil iris), keyform, lantunan rantai, ZIP, analisis penyegerakan bibir, membaca dan menolak VRM 0.x / 1.0, skinning, morph dan spring bone, serta apa yang ditulis oleh VRM Add-on untuk Blender (pemampatan yang dinamakan tetapi tidak digunakan, `KHR_texture_transform`, sampler).

## Perbezaan dan had yang diketahui

- **MToon** dianggarkan dengan bahan tanpa pencahayaan RealityKit (warna asas, tekstur, mod alfa, dua sisi). Tiada cahaya tepi atau sempadan bayang.
- Bagi **VRM**, skinning dan morph dikira pada CPU dan ditulis ke LowLevelMesh setiap bingkai. Gunakan binaan Release untuk model yang mempunyai terlalu banyak bucu.
- **Penjejakan muka** menggunakan ARKit (TrueDepth), jadi tidak tersedia pada Mac dan Vision Pro. Tanpa titik rujukan bibir, bukaan mulut hanya datang daripada `jawOpen`.
- **visionOS**: VRM setinggi kira-kira 0.36 m dalam tetingkap.

## Lesen

- Kod: Apache License 2.0, sama seperti LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Watak yang disertakan: lesen Apache **tidak** terpakai. Hanya untuk kegunaan bukan komersial, dengan atribusi. Kujira dan Kujira Q di bawah CC BY-NC-SA 4.0, dan Pen tidak diberi sebarang hak. Baca “Lesen dan Tanda Dagangan” dalam app sebelum mengedarkannya.
- Nama dan logo LivLiv tidak diliputi oleh mana-mana lesen.
