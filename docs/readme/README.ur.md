# livlivIOSPlayer

<div dir="rtl">

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · **اردو** · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

یہ پروجیکٹ ویب کے لیے 2.5D کردار پلیئر [LivLiv Player](https://github.com/livliv-dev/player) ‏(TypeScript/WebGL2) کو **iOS، macOS اور visionOS کی نیٹو ایپ** میں منتقل کرتا ہے۔ کردار **Metal** سے بنائے جاتے ہیں، اور VRM اوتار اس پروجیکٹ کے لیے **RealityKit** پر لکھے گئے glTF/VRM لوڈر سے۔

## ضروریات

- iOS 18، macOS 15 یا visionOS 2 یا اس سے نیا (Xcode 16 یا نیا، Swift 6 ٹول چین)
- کوئی بیرونی انحصار نہیں۔ ایپ کی منطق ایک مقامی Swift پیکیج (`Packages/LivLivKit`) میں ہے۔

## بلڈ

1. Xcode میں `livlivIOSPlayer.xcodeproj` کھولیں۔
2. Signing & Capabilities میں اپنا Team منتخب کریں، اور ضرورت ہو تو بنڈل شناخت کنندہ بدلیں۔
3. چلانے کی منزل کے طور پر iPhone یا iPad (آلہ یا سمیولیٹر)، My Mac یا Apple Vision Pro منتخب کریں، پھر Run ‏(⌘R) دبائیں۔

`LivLivCore` کو Debug میں بھی `-O` کے ساتھ بلڈ کیا جاتا ہے، کیونکہ رِگ ہر فریم میں دسیوں ہزار ورٹیکس ہلاتا ہے (k01: `-Onone` پر فی فریم تقریباً 17 ms، `-O` پر تقریباً 2 ms)۔

## خصوصیات

- **کردار**: ‏21 شامل کردار
- **درآمد کریں**: وہ فولڈر یا فائل منتخب کریں جو آپ نے ایپ کے Documents فولڈر میں رکھی ہو۔ ایپ پہلے جانچتی ہے کہ وہ اسے کھول سکتی ہے، پھر لوڈ کرتی ہے۔ اگر نہ کھول سکے تو ایک انتباہ وجہ ایسے ٹیکسٹ ویو میں دکھاتا ہے جسے منتخب اور کاپی کیا جا سکتا ہے۔
- Documents فولڈر: iPhone، iPad اور Vision Pro پر فائلز › On My iPhone › livlivIOSPlayer؛ Mac پر درآمد کریں میں «Finder میں Documents فولڈر کھولیں»۔ «کسی اور مقام سے منتخب کریں…» کسی اور جگہ کا فولڈر یا فائل کھولتا ہے۔
- تاثرات، حرکات اور اونگھ۔ کردار پوائنٹر کے پیچھے دیکھتا ہے، جھولتے حصے چھونے پر اچھلتے ہیں، اور چٹکی سے زوم کیا جا سکتا ہے۔
- مائیکروفون یا آڈیو فائل سے **لب ہم آہنگی**، اور TrueDepth والے iPhone یا iPad پر **چہرے کی ٹریکنگ**
- **ترتیبات**: حرکت، ریزولیوشن، چہرے کی ٹریکنگ، اور اوپن سورس لائسنسز › «لائسنسز اور ٹریڈ مارکس»

## معاون فارمیٹس

- LivLiv ماڈل فولڈر (`model.json` + `textures/`)، `.livliv` / `.zip`
- `.vrm` / `.glb` ‏(VRM 0.x / 1.0)، بشمول Blender کے VRM Add-on سے ایکسپورٹ کی گئی فائلیں
- PNGTuber فولڈر: `closed.png`، `open.png` (اختیاری: `blink.png`، `blink-open.png`، `name.txt`)

جو فائل چلائی نہ جا سکے (میش کے بغیر VRM، Draco / Meshopt / KTX2 کمپریشن، بہت بڑی تصاویر) اسے وجہ بتا کر رد کر دیا جاتا ہے۔

## مقامی کاری

- ایپ کا متن 50 زبانوں میں String Catalogs ‏(`livlivIOSPlayer/Localizable.xcstrings`، `InfoPlist.xcstrings`) میں ہے۔ ڈویلپمنٹ زبان انگریزی ہے، اور انگریزی کی علاقائی شکلیں بھی اسی کو استعمال کرتی ہیں۔
- «لائسنسز اور ٹریڈ مارکس» دستاویز کوریائی آلات پر کوریائی میں اور باقی جگہ انگریزی میں دکھتی ہے۔ کرداروں کے نام، انتساب اور لائسنسوں کے اصل متن کا ترجمہ نہیں کیا جاتا۔
- یہ README انہی زبانوں میں دستیاب ہے (اوپر لنکس)۔ تراجم کا ابھی اہلِ زبان نے جائزہ نہیں لیا، اس لیے اصلاحات کا خیرمقدم ہے۔

## پروجیکٹ کی ساخت

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

## اصل ← منتقلی

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

## ٹیسٹ

```sh
cd Packages/LivLivKit
swift test
```

Linux پر جانچا گیا: 21 شامل کرداروں کو پڑھنا اور ہر ایک کے 240 فریم چلانا (تاثرات، حرکات، منہ، آئرس اسٹینسل)، keyforms، زنجیروں کا اچھلنا، ZIP، لب ہم آہنگی کا تجزیہ، VRM 0.x / 1.0 کو پڑھنا اور رد کرنا، skinning، morphs اور spring bones، اور وہ جو Blender کا VRM Add-on لکھتا ہے (نام دیا گیا مگر غیر استعمال شدہ کمپریشن، `KHR_texture_transform`، samplers)۔

## معلوم فرق اور حدود

- **MToon** کو RealityKit کے بغیر روشنی والے مٹیریل سے قریب لایا جاتا ہے (بنیادی رنگ، ٹیکسچر، الفا موڈ، دو رُخی)۔ رِم لائٹ اور سائے کی حد نہیں ہے۔
- **VRM** میں skinning اور morphs CPU پر حساب ہوتے ہیں اور ہر فریم LowLevelMesh میں لکھے جاتے ہیں۔ بہت زیادہ ورٹیکس والے ماڈلز کے لیے Release بلڈ استعمال کریں۔
- **چہرے کی ٹریکنگ** ARKit ‏(TrueDepth) استعمال کرتی ہے، اس لیے Mac اور Vision Pro پر دستیاب نہیں۔ ہونٹوں کے نشانات نہ ہونے سے منہ کا کھلنا صرف `jawOpen` سے طے ہوتا ہے۔
- **visionOS**: VRM ونڈو میں تقریباً 0.36 m اونچا ہوتا ہے۔

## لائسنس

- کوڈ: LivLiv Player کی طرح Apache License 2.0 ‏(`livlivIOSPlayer/Resources/Legal/`)۔
- شامل کردار: ان پر Apache لائسنس **لاگو نہیں** ہوتا۔ صرف غیر تجارتی استعمال، انتساب کے ساتھ۔ Kujira اور Kujira Q کا لائسنس CC BY-NC-SA 4.0 ہے، اور Pen کے لیے کوئی حق نہیں دیا گیا۔ تقسیم سے پہلے ایپ میں «لائسنسز اور ٹریڈ مارکس» پڑھیں۔
- LivLiv کا نام اور لوگو کسی لائسنس میں شامل نہیں۔

</div>
