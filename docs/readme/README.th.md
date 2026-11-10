# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · **ไทย** · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

โปรเจกต์นี้พอร์ต [LivLiv Player](https://github.com/livliv-dev/player) ซึ่งเป็นเพลเยอร์ตัวละคร 2.5D สำหรับเว็บ (TypeScript/WebGL2) มาเป็น**แอปเนทีฟสำหรับ iOS, macOS และ visionOS** ตัวละครวาดด้วย **Metal** และอวาตาร์ VRM วาดด้วยตัวโหลด glTF/VRM ที่เขียนขึ้นสำหรับโปรเจกต์นี้บน **RealityKit**

## ข้อกำหนด

- iOS 18, macOS 15 หรือ visionOS 2 ขึ้นไป (Xcode 16 ขึ้นไป, ชุดเครื่องมือ Swift 6)
- ไม่มีการพึ่งพาภายนอก ตรรกะของแอปอยู่ในแพ็กเกจ Swift ภายในเครื่อง (`Packages/LivLivKit`)

## การบิลด์

1. เปิด `livlivIOSPlayer.xcodeproj` ใน Xcode
2. ใน Signing & Capabilities ให้เลือก Team ของคุณเอง และเปลี่ยนตัวระบุบันเดิลหากจำเป็น
3. เลือก iPhone หรือ iPad (อุปกรณ์หรือเครื่องจำลอง), My Mac หรือ Apple Vision Pro เป็นปลายทาง แล้วกด Run (⌘R)

`LivLivCore` บิลด์ด้วย `-O` แม้ใน Debug เพราะริกขยับเวอร์เท็กซ์หลายหมื่นจุดในแต่ละเฟรม (k01: ประมาณ 17 ms ต่อเฟรมเมื่อใช้ `-Onone` และประมาณ 2 ms เมื่อใช้ `-O`)

## คุณสมบัติ

- **ตัวละคร**: ตัวละครที่ให้มา 21 ตัว
- **นำเข้า**: เลือกโฟลเดอร์หรือไฟล์ที่คุณวางไว้ในโฟลเดอร์ Documents ของแอป แอปจะตรวจสอบก่อนว่าเปิดได้หรือไม่ แล้วจึงโหลด หากเปิดไม่ได้ จะมีการแจ้งเตือนแสดงสาเหตุในมุมมองข้อความที่เลือกและคัดลอกได้
- โฟลเดอร์ Documents: บน iPhone, iPad และ Vision Pro อยู่ที่ ไฟล์ › บน iPhone ของฉัน › livlivIOSPlayer บน Mac ใช้ “เปิดโฟลเดอร์ Documents ใน Finder” ในนำเข้า ส่วน “เลือกจากตำแหน่งอื่น…” ใช้เปิดโฟลเดอร์หรือไฟล์จากที่อื่น
- สีหน้า ท่าทาง และการงีบ ตัวละครมองตามตัวชี้ ส่วนที่แกว่งจะเด้งเมื่อแตะ และจีบนิ้วเพื่อซูมได้
- **ลิปซิงค์**จากไมโครโฟนหรือไฟล์เสียง และ**การติดตามใบหน้า**บน iPhone หรือ iPad ที่มี TrueDepth
- **การตั้งค่า**: การเคลื่อนไหว ความละเอียด การติดตามใบหน้า และใบอนุญาตโอเพนซอร์ส › “ใบอนุญาตและเครื่องหมายการค้า”

## รูปแบบที่รองรับ

- โฟลเดอร์โมเดล LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0) รวมถึงไฟล์ที่ส่งออกด้วย VRM Add-on สำหรับ Blender
- โฟลเดอร์ PNGTuber: `closed.png`, `open.png` (ไม่บังคับ: `blink.png`, `blink-open.png`, `name.txt`)

ไฟล์ที่เล่นไม่ได้ (VRM ที่ไม่มีเมช การบีบอัด Draco / Meshopt / KTX2 ภาพที่ใหญ่เกินไป) จะถูกปฏิเสธพร้อมสาเหตุ

## การแปลภาษา

- ข้อความของแอปมี 50 ภาษา อยู่ใน String Catalog (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`) ภาษาที่ใช้พัฒนาคือภาษาอังกฤษ และภาษาอังกฤษแต่ละภูมิภาคก็ใช้ภาษานี้
- เอกสาร “ใบอนุญาตและเครื่องหมายการค้า” จะแสดงเป็นภาษาเกาหลีบนอุปกรณ์ภาษาเกาหลี และเป็นภาษาอังกฤษในกรณีอื่น ชื่อตัวละคร เครดิต และข้อความต้นฉบับของใบอนุญาตจะไม่ถูกแปล
- README นี้มีในภาษาเดียวกัน (ลิงก์ด้านบน) คำแปลยังไม่ผ่านการตรวจทานจากเจ้าของภาษา จึงยินดีรับการแก้ไข

## โครงสร้างโปรเจกต์

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

## ต้นฉบับ → พอร์ต

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

## การทดสอบ

```sh
cd Packages/LivLivKit
swift test
```

ตรวจสอบบน Linux: การอ่านตัวละคร 21 ตัวที่ให้มาและเล่น 240 เฟรมของแต่ละตัว (สีหน้า ท่าทาง ปาก สเตนซิลม่านตา), keyforms, การเด้งของโซ่, ZIP, การวิเคราะห์ลิปซิงค์, การอ่านและปฏิเสธ VRM 0.x / 1.0, skinning, morphs และ spring bones รวมถึงสิ่งที่ VRM Add-on สำหรับ Blender เขียนไว้ (การบีบอัดที่ระบุชื่อแต่ไม่ได้ใช้, `KHR_texture_transform`, samplers)

## ความแตกต่างและข้อจำกัดที่ทราบ

- **MToon** จำลองด้วยวัสดุไม่รับแสงของ RealityKit (สีพื้นฐาน เท็กซ์เจอร์ โหมดอัลฟา สองด้าน) ไม่มีแสงขอบและเส้นแบ่งเงา
- ใน **VRM** การคำนวณ skinning และ morphs ทำบน CPU และเขียนลง LowLevelMesh ทุกเฟรม สำหรับโมเดลที่มีเวอร์เท็กซ์จำนวนมากให้ใช้บิลด์ Release
- **การติดตามใบหน้า**ใช้ ARKit (TrueDepth) จึงใช้ไม่ได้บน Mac และ Vision Pro เนื่องจากไม่มีจุดอ้างอิงของริมฝีปาก การอ้าปากจึงมาจาก `jawOpen` เท่านั้น
- **visionOS**: VRM สูงประมาณ 0.36 m ในหน้าต่าง

## ใบอนุญาต

- โค้ด: Apache License 2.0 เช่นเดียวกับ LivLiv Player (`livlivIOSPlayer/Resources/Legal/`)
- ตัวละครที่ให้มา: **ไม่**อยู่ภายใต้ใบอนุญาต Apache ใช้ได้เฉพาะที่ไม่ใช่เชิงพาณิชย์และต้องให้เครดิต Kujira และ Kujira Q ใช้ CC BY-NC-SA 4.0 ส่วน Pen ไม่ได้ให้สิทธิ์ใดๆ เลย โปรดอ่าน “ใบอนุญาตและเครื่องหมายการค้า” ในแอปก่อนแจกจ่าย
- ชื่อและโลโก้ LivLiv ไม่อยู่ภายใต้ใบอนุญาตใดๆ
