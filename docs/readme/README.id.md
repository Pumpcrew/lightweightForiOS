# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · **Bahasa Indonesia** · [Bahasa Melayu](README.ms.md)

Proyek ini memindahkan [LivLiv Player](https://github.com/livliv-dev/player), pemutar karakter 2.5D untuk web (TypeScript/WebGL2), menjadi **app native untuk iOS, macOS, dan visionOS**. Karakter digambar dengan **Metal**, dan avatar VRM dengan pemuat glTF/VRM yang ditulis untuk proyek ini di atas **RealityKit**.

## Persyaratan

- iOS 18, macOS 15, atau visionOS 2 atau lebih baru (Xcode 16 atau lebih baru, toolchain Swift 6)
- Tanpa dependensi luar. Logika app berada di paket Swift lokal (`Packages/LivLivKit`).

## Build

1. Buka `livlivIOSPlayer.xcodeproj` di Xcode.
2. Di Signing & Capabilities, pilih Team Anda sendiri, dan ubah ID bundel bila perlu.
3. Pilih iPhone atau iPad (perangkat atau simulator), My Mac, atau Apple Vision Pro sebagai tujuan, lalu tekan Run (⌘R).

`LivLivCore` di-build dengan `-O` bahkan di Debug, karena rig menggerakkan puluhan ribu verteks setiap frame (k01: sekitar 17 ms per frame dengan `-Onone`, sekitar 2 ms dengan `-O`).

## Fitur

- **Karakter**: 21 karakter bawaan
- **Impor**: pilih folder atau file yang Anda taruh di folder Documents app. App terlebih dahulu memeriksa apakah bisa membukanya, lalu memuatnya. Jika tidak bisa, peringatan menampilkan alasannya dalam tampilan teks yang dapat dipilih dan disalin.
- Folder Documents: di iPhone, iPad, dan Vision Pro ada di File › Di iPhone Saya › livlivIOSPlayer; di Mac melalui “Buka Folder Documents di Finder” di Impor. “Pilih dari Lokasi Lain…” membuka folder atau file dari tempat lain.
- Ekspresi, aksi, dan terkantuk. Karakter mengikuti penunjuk, bagian yang berayun memantul saat diketuk, dan Anda dapat mencubit untuk zoom.
- **Sinkronisasi bibir** dari mikrofon atau file audio, dan **pelacakan wajah** di iPhone atau iPad dengan TrueDepth
- **Pengaturan**: gerakan, resolusi, pelacakan wajah, dan Lisensi Sumber Terbuka › “Lisensi dan Merek Dagang”

## Format yang didukung

- Folder model LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), termasuk file yang diekspor dengan VRM Add-on untuk Blender
- Folder PNGTuber: `closed.png`, `open.png` (opsional: `blink.png`, `blink-open.png`, `name.txt`)

File yang tidak dapat diputar (VRM tanpa mesh, kompresi Draco / Meshopt / KTX2, gambar terlalu besar) ditolak beserta alasannya.

## Lokalisasi

- Teks app tersedia dalam 50 bahasa, di String Catalog (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Bahasa pengembangan adalah bahasa Inggris, yang juga dipakai varian regional bahasa Inggris.
- Dokumen “Lisensi dan Merek Dagang” tampil dalam bahasa Korea di perangkat berbahasa Korea dan dalam bahasa Inggris di perangkat lain. Nama karakter, kredit, dan teks asli lisensi tidak diterjemahkan.
- README ini tersedia dalam bahasa yang sama (tautan di atas). Terjemahan belum ditinjau penutur asli, jadi koreksi sangat diterima.

## Struktur proyek

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

## Asli → port

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

## Pengujian

```sh
cd Packages/LivLivKit
swift test
```

Diperiksa di Linux: membaca 21 karakter bawaan dan memutar 240 frame masing-masing (ekspresi, aksi, mulut, stencil iris), keyform, pantulan rantai, ZIP, analisis sinkronisasi bibir, membaca dan menolak VRM 0.x / 1.0, skinning, morph, dan spring bone, serta apa yang ditulis VRM Add-on untuk Blender (kompresi yang disebut tetapi tidak dipakai, `KHR_texture_transform`, sampler).

## Perbedaan dan batasan yang diketahui

- **MToon** didekati dengan material tanpa pencahayaan RealityKit (warna dasar, tekstur, mode alfa, dua sisi). Tidak ada cahaya tepi maupun batas bayangan.
- Pada **VRM**, skinning dan morph dihitung di CPU dan ditulis ke LowLevelMesh setiap frame. Gunakan build Release untuk model dengan sangat banyak verteks.
- **Pelacakan wajah** memakai ARKit (TrueDepth), sehingga tidak tersedia di Mac dan Vision Pro. Tanpa titik acuan bibir, bukaan mulut hanya berasal dari `jawOpen`.
- **visionOS**: VRM setinggi sekitar 0,36 m di dalam jendela.

## Lisensi

- Kode: Apache License 2.0, sama dengan LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Karakter bawaan: lisensi Apache **tidak** berlaku. Hanya untuk penggunaan nonkomersial, dengan atribusi. Kujira dan Kujira Q berlisensi CC BY-NC-SA 4.0, dan Pen tidak diberi hak apa pun. Baca “Lisensi dan Merek Dagang” di app sebelum mendistribusikannya.
- Nama dan logo LivLiv tidak tercakup oleh lisensi apa pun.
