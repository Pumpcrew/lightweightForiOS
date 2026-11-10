# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · **Tiếng Việt** · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Dự án này chuyển [LivLiv Player](https://github.com/livliv-dev/player), trình phát nhân vật 2.5D cho web (TypeScript/WebGL2), thành **ứng dụng gốc cho iOS, macOS và visionOS**. Nhân vật được vẽ bằng **Metal**, còn avatar VRM được vẽ bằng trình tải glTF/VRM viết riêng cho dự án trên **RealityKit**.

## Yêu cầu

- iOS 18, macOS 15 hoặc visionOS 2 trở lên (Xcode 16 trở lên, bộ công cụ Swift 6)
- Không có phụ thuộc bên ngoài. Logic của ứng dụng nằm trong một gói Swift cục bộ (`Packages/LivLivKit`).

## Biên dịch

1. Mở `livlivIOSPlayer.xcodeproj` trong Xcode.
2. Trong Signing & Capabilities, chọn Team của bạn và đổi mã định danh gói nếu cần.
3. Chọn iPhone hoặc iPad (thiết bị hoặc trình mô phỏng), My Mac hoặc Apple Vision Pro làm đích chạy, rồi nhấn Run (⌘R).

`LivLivCore` được biên dịch với `-O` ngay cả ở Debug, vì rig di chuyển hàng chục nghìn đỉnh mỗi khung hình (k01: khoảng 17 ms mỗi khung với `-Onone`, khoảng 2 ms với `-O`).

## Tính năng

- **Nhân vật**: 21 nhân vật đi kèm
- **Nhập**: chọn thư mục hoặc tệp bạn đã đặt vào thư mục Documents của ứng dụng. Ứng dụng kiểm tra trước xem có mở được không rồi mới tải. Nếu không, một cảnh báo hiển thị lý do trong ô văn bản có thể chọn và sao chép.
- Thư mục Documents: trên iPhone, iPad và Vision Pro là Tệp › Trên iPhone › livlivIOSPlayer; trên Mac là “Mở thư mục Documents trong Finder” trong Nhập. “Chọn từ vị trí khác…” mở thư mục hoặc tệp ở nơi khác.
- Biểu cảm, hành động và ngủ gật. Nhân vật nhìn theo con trỏ, các phần đung đưa nảy lên khi chạm và bạn có thể chụm để phóng to.
- **Đồng bộ môi** từ micrô hoặc tệp âm thanh, và **theo dõi khuôn mặt** trên iPhone hoặc iPad có TrueDepth
- **Cài đặt**: chuyển động, độ phân giải, theo dõi khuôn mặt và Giấy phép nguồn mở › “Giấy phép và nhãn hiệu”

## Định dạng được hỗ trợ

- Thư mục mô hình LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), kể cả tệp xuất bằng VRM Add-on cho Blender
- Thư mục PNGTuber: `closed.png`, `open.png` (tùy chọn: `blink.png`, `blink-open.png`, `name.txt`)

Tệp không phát được (VRM không có lưới, nén Draco / Meshopt / KTX2, ảnh quá lớn) sẽ bị từ chối kèm lý do.

## Bản địa hóa

- Văn bản của ứng dụng có 50 ngôn ngữ, trong String Catalog (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Ngôn ngữ phát triển là tiếng Anh, và các biến thể tiếng Anh theo vùng cũng dùng nó.
- Tài liệu “Giấy phép và nhãn hiệu” hiển thị bằng tiếng Hàn trên thiết bị tiếng Hàn và bằng tiếng Anh ở nơi khác. Tên nhân vật, ghi công và văn bản gốc của giấy phép không được dịch.
- README này có ở cùng các ngôn ngữ (liên kết ở trên cùng). Bản dịch chưa được người bản ngữ xem lại, nên rất hoan nghênh các chỉnh sửa.

## Cấu trúc dự án

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

## Bản gốc → bản chuyển

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

## Kiểm thử

```sh
cd Packages/LivLivKit
swift test
```

Đã kiểm tra trên Linux: đọc 21 nhân vật đi kèm và chạy 240 khung hình mỗi nhân vật (biểu cảm, hành động, miệng, stencil mống mắt), keyforms, độ nảy của chuỗi, ZIP, phân tích đồng bộ môi, đọc và từ chối VRM 0.x / 1.0, skinning, morph và spring bone, cùng những gì VRM Add-on cho Blender ghi ra (nén có tên nhưng không dùng, `KHR_texture_transform`, sampler).

## Khác biệt và giới hạn đã biết

- **MToon** được mô phỏng bằng vật liệu không chiếu sáng của RealityKit (màu cơ bản, texture, chế độ alpha, hai mặt). Không có ánh sáng viền và ranh giới bóng.
- Với **VRM**, skinning và morph được tính trên CPU và ghi vào LowLevelMesh mỗi khung hình. Hãy dùng bản Release cho mô hình có rất nhiều đỉnh.
- **Theo dõi khuôn mặt** dùng ARKit (TrueDepth) nên không có trên Mac và Vision Pro. Do không có điểm mốc môi, độ mở miệng chỉ lấy từ `jawOpen`.
- **visionOS**: VRM cao khoảng 0,36 m trong cửa sổ.

## Giấy phép

- Mã nguồn: Apache License 2.0, giống LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Nhân vật đi kèm: giấy phép Apache **không** áp dụng. Chỉ dùng phi thương mại, có ghi công. Kujira và Kujira Q theo CC BY-NC-SA 4.0, còn Pen không được trao bất kỳ quyền nào. Hãy đọc “Giấy phép và nhãn hiệu” trong ứng dụng trước khi phân phối.
- Tên và logo LivLiv không thuộc phạm vi của bất kỳ giấy phép nào.
