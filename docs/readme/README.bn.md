# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · **বাংলা** · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

এই প্রজেক্টটি ওয়েবের জন্য তৈরি 2.5D চরিত্র প্লেয়ার [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2)-কে **iOS, macOS ও visionOS-এর নেটিভ অ্যাপে** রূপান্তর করে। চরিত্রগুলো **Metal** দিয়ে আঁকা হয়, আর VRM অবতার এই প্রজেক্টের জন্য **RealityKit**-এর ওপর লেখা glTF/VRM লোডার দিয়ে।

## প্রয়োজনীয়তা

- iOS 18, macOS 15 বা visionOS 2 বা পরবর্তী (Xcode 16 বা পরবর্তী, Swift 6 টুলচেইন)
- কোনো বাইরের নির্ভরতা নেই। অ্যাপের লজিক একটি লোকাল Swift প্যাকেজে (`Packages/LivLivKit`) আছে।

## বিল্ড

1. Xcode-এ `livlivIOSPlayer.xcodeproj` খুলুন।
2. Signing & Capabilities-এ নিজের Team বেছে নিন, দরকার হলে বান্ডল আইডেন্টিফায়ার বদলান।
3. রান গন্তব্য হিসেবে iPhone বা iPad (ডিভাইস বা সিমুলেটর), My Mac বা Apple Vision Pro বেছে নিয়ে Run (⌘R) চাপুন।

`LivLivCore` Debug-এও `-O` দিয়ে বিল্ড হয়, কারণ রিগ প্রতি ফ্রেমে কয়েক হাজার ভার্টেক্স সরায় (k01: `-Onone`-এ প্রতি ফ্রেমে প্রায় 17 ms, `-O`-এ প্রায় 2 ms)।

## বৈশিষ্ট্য

- **চরিত্র**: 21টি অন্তর্ভুক্ত চরিত্র
- **ইমপোর্ট**: অ্যাপের Documents ফোল্ডারে রাখা ফোল্ডার বা ফাইল বেছে নিন। অ্যাপ আগে দেখে নেয় সেটি খোলা যায় কি না, তারপর লোড করে। না পারলে একটি সতর্কবার্তা কারণটি এমন টেক্সট ভিউতে দেখায় যা বেছে নেওয়া ও কপি করা যায়।
- Documents ফোল্ডার: iPhone, iPad ও Vision Pro-তে ফাইলস › আমার iPhone-এ › livlivIOSPlayer; Mac-এ ইমপোর্ট-এর “Finder-এ Documents ফোল্ডার খুলুন”। “অন্য অবস্থান থেকে বেছে নিন…” অন্য জায়গার ফোল্ডার বা ফাইল খোলে।
- অভিব্যক্তি, অ্যাকশন ও ঝিমুনি। চরিত্রটি পয়েন্টার অনুসরণ করে, দোলা অংশগুলো ছুঁলে লাফিয়ে ওঠে, আর পিঞ্চ করে জুম করা যায়।
- মাইক্রোফোন বা অডিও ফাইল থেকে **লিপ সিঙ্ক**, আর TrueDepth-যুক্ত iPhone বা iPad-এ **মুখ ট্র্যাকিং**
- **সেটিংস**: গতি, রেজোলিউশন, মুখ ট্র্যাকিং, এবং ওপেন সোর্স লাইসেন্স › “লাইসেন্স ও ট্রেডমার্ক”

## সমর্থিত ফরম্যাট

- LivLiv মডেল ফোল্ডার (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender-এর VRM Add-on দিয়ে এক্সপোর্ট করা ফাইলসহ
- PNGTuber ফোল্ডার: `closed.png`, `open.png` (ঐচ্ছিক: `blink.png`, `blink-open.png`, `name.txt`)

যে ফাইল চালানো যায় না (মেশহীন VRM, Draco / Meshopt / KTX2 কম্প্রেশন, খুব বড় ছবি) তা কারণসহ প্রত্যাখ্যান করা হয়।

## স্থানীয়করণ

- অ্যাপের লেখা 50টি ভাষায় String Catalog-এ (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`) আছে। ডেভেলপমেন্ট ভাষা ইংরেজি, আর ইংরেজির আঞ্চলিক রূপগুলোও সেটিই ব্যবহার করে।
- “লাইসেন্স ও ট্রেডমার্ক” নথিটি কোরীয় ডিভাইসে কোরীয় ভাষায় এবং অন্যত্র ইংরেজিতে দেখায়। চরিত্রের নাম, কৃতিত্ব এবং লাইসেন্সের মূল লেখা অনুবাদ করা হয় না।
- এই README একই ভাষাগুলোতে পাওয়া যায় (ওপরে লিংক)। অনুবাদগুলো এখনো মাতৃভাষীরা যাচাই করেননি, তাই সংশোধন স্বাগত।

## প্রজেক্টের গঠন

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

## মূল → পোর্ট

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

## টেস্ট

```sh
cd Packages/LivLivKit
swift test
```

Linux-এ যাচাই করা হয়েছে: 21টি অন্তর্ভুক্ত চরিত্র পড়া এবং প্রতিটির 240 ফ্রেম চালানো (অভিব্যক্তি, অ্যাকশন, মুখ, আইরিস স্টেনসিল), keyforms, চেইনের লাফানো, ZIP, লিপ সিঙ্ক বিশ্লেষণ, VRM 0.x / 1.0 পড়া ও প্রত্যাখ্যান, skinning, morphs ও spring bones, এবং Blender-এর VRM Add-on যা লেখে (নাম আছে কিন্তু ব্যবহার হয়নি এমন কম্প্রেশন, `KHR_texture_transform`, samplers)।

## জানা পার্থক্য ও সীমাবদ্ধতা

- **MToon**-কে RealityKit-এর আলোবিহীন ম্যাটেরিয়াল দিয়ে কাছাকাছি দেখানো হয় (মূল রং, টেক্সচার, আলফা মোড, দুই দিক)। রিম লাইট ও ছায়ার সীমা নেই।
- **VRM**-এ skinning ও morphs CPU-তে হিসাব হয় এবং প্রতি ফ্রেমে LowLevelMesh-এ লেখা হয়। খুব বেশি ভার্টেক্সের মডেলের জন্য Release বিল্ড ব্যবহার করুন।
- **মুখ ট্র্যাকিং** ARKit (TrueDepth) ব্যবহার করে, তাই Mac ও Vision Pro-তে পাওয়া যায় না। ঠোঁটের ল্যান্ডমার্ক না থাকায় মুখ খোলা শুধু `jawOpen` থেকে নির্ধারিত হয়।
- **visionOS**: উইন্ডোতে VRM প্রায় 0.36 m উঁচু হয়।

## লাইসেন্স

- কোড: LivLiv Player-এর মতোই Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`)।
- অন্তর্ভুক্ত চরিত্র: এগুলোর ওপর Apache লাইসেন্স **প্রযোজ্য নয়**। শুধু অবাণিজ্যিক ব্যবহার, কৃতিত্ব দিয়ে। Kujira ও Kujira Q-এর লাইসেন্স CC BY-NC-SA 4.0, আর Pen-এর জন্য কোনো অধিকার দেওয়া হয়নি। বিতরণের আগে অ্যাপে “লাইসেন্স ও ট্রেডমার্ক” পড়ুন।
- LivLiv নাম ও লোগো কোনো লাইসেন্সের আওতায় নেই।
