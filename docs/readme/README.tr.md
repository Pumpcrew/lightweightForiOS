# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · **Türkçe** · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Bu proje, web için bir 2.5D karakter oynatıcısı olan [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2) uygulamasını **iOS, macOS ve visionOS için yerel bir uygulamaya** taşır. Karakterler **Metal** ile, VRM avatarları ise bu proje için **RealityKit** üzerine yazılmış bir glTF/VRM yükleyiciyle çizilir.

## Gereksinimler

- iOS 18, macOS 15 veya visionOS 2 ya da sonrası (Xcode 16 ya da sonrası, Swift 6 araç zinciri)
- Dış bağımlılık yok. Uygulamanın mantığı yerel bir Swift paketindedir (`Packages/LivLivKit`).

## Derleme

1. `livlivIOSPlayer.xcodeproj` dosyasını Xcode’da açın.
2. Signing & Capabilities bölümünde kendi Team’inizi seçin ve gerekirse paket kimliğini değiştirin.
3. Hedef olarak bir iPhone veya iPad (aygıt ya da simülatör), My Mac veya Apple Vision Pro seçin, ardından Run (⌘R) düğmesine basın.

`LivLivCore`, rig her karede on binlerce köşeyi hareket ettirdiği için Debug’da bile `-O` ile derlenir (k01: `-Onone` ile kare başına yaklaşık 17 ms, `-O` ile yaklaşık 2 ms).

## Özellikler

- **Karakterler**: birlikte gelen 21 karakter
- **İçe Aktar**: uygulamanın Documents klasörüne koyduğunuz bir klasörü veya dosyayı seçin. Uygulama önce onu açabildiğini denetler, sonra yükler. Açamazsa, bir uyarı nedeni seçilip kopyalanabilen bir metin görünümünde gösterir.
- Documents klasörü: iPhone, iPad ve Vision Pro’da Dosyalar › iPhone’umda › livlivIOSPlayer; Mac’te İçe Aktar içindeki “Documents Klasörünü Finder’da Aç”. “Başka Bir Konumdan Seç…” başka bir yerdeki klasörü veya dosyayı açar.
- İfadeler, eylemler ve uyuklama. Karakter imleci izler, sallanan parçalar dokununca sekip yaylanır ve kıstırarak yakınlaştırabilirsiniz.
- Mikrofondan veya bir ses dosyasından **dudak senkronu** ve TrueDepth’li iPhone ya da iPad’de **yüz takibi**
- **Ayarlar**: hareket, çözünürlük, yüz takibi ve Açık Kaynak Lisansları › “Lisanslar ve Ticari Markalar”

## Desteklenen biçimler

- LivLiv model klasörü (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender için VRM Add-on ile dışa aktarılan dosyalar dahil
- PNGTuber klasörü: `closed.png`, `open.png` (isteğe bağlı: `blink.png`, `blink-open.png`, `name.txt`)

Oynatılamayan bir dosya (ağı olmayan bir VRM, Draco / Meshopt / KTX2 sıkıştırması, fazla büyük görüntüler) nedeni belirtilerek reddedilir.

## Yerelleştirme

- Uygulamanın metinleri 50 dilde, String Catalog’larda yer alır (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Geliştirme dili İngilizcedir; İngilizcenin bölgesel türevleri de onu kullanır.
- “Lisanslar ve Ticari Markalar” belgesi Korece aygıtlarda Korece, diğerlerinde İngilizce gösterilir. Karakter adları, emeği geçenler ve lisansların özgün metinleri çevrilmez.
- Bu README aynı dillerde de vardır (bağlantılar en üstte). Çeviriler henüz ana dili konuşanlarca gözden geçirilmedi, bu yüzden düzeltmeler memnuniyetle karşılanır.

## Proje yapısı

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

## Özgün → taşıma

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

## Testler

```sh
cd Packages/LivLivKit
swift test
```

Linux’ta denetlendi: birlikte gelen 21 karakterin okunması ve her birinden 240 kare (ifadeler, eylemler, ağız, iris şablonu), keyform’lar, zincirlerin yaylanması, ZIP, dudak senkronu çözümlemesi, VRM 0.x / 1.0 okuma ve reddetme, skinning, morph’lar ve spring bone’lar ile Blender için VRM Add-on’un yazdıkları (adı geçen ama kullanılmayan sıkıştırma, `KHR_texture_transform`, sampler’lar).

## Bilinen farklar ve sınırlar

- **MToon**, RealityKit’in ışıksız malzemesiyle yaklaşık olarak gösterilir (temel renk, doku, alfa modu, çift yüz). Kenar ışığı ve gölge sınırı yoktur.
- **VRM**’de skinning ve morph’lar CPU’da hesaplanır ve her karede bir LowLevelMesh’e yazılır. Çok fazla köşesi olan modeller için Release derlemesi kullanın.
- **Yüz takibi** ARKit (TrueDepth) kullandığından Mac’te ve Vision Pro’da yoktur. Dudak noktaları olmadığından ağzın açılması yalnızca `jawOpen` ile belirlenir.
- **visionOS**: bir VRM pencerede yaklaşık 0,36 m boyundadır.

## Lisans

- Kod: LivLiv Player ile aynı Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`).
- Birlikte gelen karakterler: Apache lisansı bunlara **uygulanmaz**. Yalnızca ticari olmayan kullanım, atıfla. Kujira ve Kujira Q CC BY-NC-SA 4.0 lisanslıdır; Pen için hiçbir hak verilmez. Dağıtmadan önce uygulamadaki “Lisanslar ve Ticari Markalar” belgesini okuyun.
- LivLiv adı ve logosu hiçbir lisansın kapsamında değildir.
