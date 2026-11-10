# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · **मराठी** · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

हा प्रोजेक्ट वेबसाठीचा 2.5D पात्र प्लेयर [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2) **iOS, macOS आणि visionOS च्या नेटिव्ह ॲप**मध्ये रूपांतरित करतो. पात्रे **Metal** ने काढली जातात, आणि VRM अवतार या प्रोजेक्टसाठी **RealityKit** वर लिहिलेल्या glTF/VRM लोडरने.

## आवश्यकता

- iOS 18, macOS 15 किंवा visionOS 2 किंवा नंतरचे (Xcode 16 किंवा नंतरचे, Swift 6 टूलचेन)
- कोणतीही बाह्य अवलंबित्वे नाहीत. ॲपचे लॉजिक स्थानिक Swift पॅकेजमध्ये (`Packages/LivLivKit`) आहे.

## बिल्ड

1. Xcode मध्ये `livlivIOSPlayer.xcodeproj` उघडा.
2. Signing & Capabilities मध्ये तुमची Team निवडा, आणि गरज असल्यास बंडल आयडेंटिफायर बदला.
3. रन गंतव्य म्हणून iPhone किंवा iPad (डिव्हाइस किंवा सिम्युलेटर), My Mac किंवा Apple Vision Pro निवडा, मग Run (⌘R) दाबा.

`LivLivCore` Debug मध्येही `-O` ने बिल्ड होतो, कारण रिग प्रत्येक फ्रेममध्ये हजारो वर्टेक्स हलवतो (k01: `-Onone` वर प्रति फ्रेम सुमारे 17 ms, `-O` वर सुमारे 2 ms).

## वैशिष्ट्ये

- **पात्रे**: 21 समाविष्ट पात्रे
- **इंपोर्ट करा**: ॲपच्या Documents फोल्डरमध्ये ठेवलेले फोल्डर किंवा फाइल निवडा. ॲप आधी ते उघडता येते का हे तपासते, मग लोड करते. न जमल्यास, एक सूचना कारण निवडता व कॉपी करता येणाऱ्या टेक्स्ट व्ह्यूमध्ये दाखवते.
- Documents फोल्डर: iPhone, iPad आणि Vision Pro वर फाइल्स › माझ्या iPhone वर › livlivIOSPlayer; Mac वर इंपोर्ट करा मधील “Finder मध्ये Documents फोल्डर उघडा”. “दुसऱ्या ठिकाणाहून निवडा…” दुसऱ्या ठिकाणचे फोल्डर किंवा फाइल उघडते.
- हावभाव, क्रिया आणि डुलकी. पात्र पॉइंटरचा पाठलाग करते, झुलणारे भाग स्पर्श केल्यावर उसळतात, आणि पिंच करून झूम करता येते.
- मायक्रोफोन किंवा ऑडिओ फाइलवरून **लिप सिंक**, आणि TrueDepth असलेल्या iPhone किंवा iPad वर **चेहरा ट्रॅकिंग**
- **सेटिंग्ज**: हालचाल, रिझोल्यूशन, चेहरा ट्रॅकिंग, आणि ओपन सोर्स परवाने › “परवाने आणि ट्रेडमार्क”

## समर्थित फॉरमॅट

- LivLiv मॉडेल फोल्डर (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender साठीच्या VRM Add-on ने एक्सपोर्ट केलेल्या फाइलींसह
- PNGTuber फोल्डर: `closed.png`, `open.png` (पर्यायी: `blink.png`, `blink-open.png`, `name.txt`)

जी फाइल चालवता येत नाही (मेश नसलेले VRM, Draco / Meshopt / KTX2 कॉम्प्रेशन, खूप मोठ्या प्रतिमा) ती कारणासह नाकारली जाते.

## स्थानिकीकरण

- ॲपचा मजकूर 50 भाषांमध्ये String Catalogs (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`) मध्ये आहे. विकास भाषा इंग्रजी आहे, आणि इंग्रजीची प्रादेशिक रूपेही तीच वापरतात.
- “परवाने आणि ट्रेडमार्क” दस्तऐवज कोरियन डिव्हाइसवर कोरियनमध्ये आणि इतरत्र इंग्रजीत दिसतो. पात्रांची नावे, श्रेय आणि परवान्यांचा मूळ मजकूर अनुवादित केला जात नाही.
- हा README याच भाषांमध्ये उपलब्ध आहे (वरील लिंक). अनुवादांचे अद्याप मातृभाषकांनी पुनरावलोकन केलेले नाही, त्यामुळे सुधारणांचे स्वागत आहे.

## प्रोजेक्टची रचना

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

## मूळ → पोर्ट

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

## चाचण्या

```sh
cd Packages/LivLivKit
swift test
```

Linux वर तपासले: 21 समाविष्ट पात्रे वाचणे आणि प्रत्येकाच्या 240 फ्रेम चालवणे (हावभाव, क्रिया, तोंड, आयरिस स्टेन्सिल), keyforms, साखळ्यांचे उसळणे, ZIP, लिप सिंक विश्लेषण, VRM 0.x / 1.0 वाचणे आणि नाकारणे, skinning, morphs आणि spring bones, आणि Blender साठीचे VRM Add-on जे लिहिते ते (नाव आहे पण न वापरलेले कॉम्प्रेशन, `KHR_texture_transform`, samplers).

## ज्ञात फरक आणि मर्यादा

- **MToon** हे RealityKit च्या प्रकाशरहित मटेरियलने अंदाजे दाखवले जाते (मूळ रंग, टेक्सचर, अल्फा मोड, दोन्ही बाजू). रिम लाइट आणि सावलीची सीमा नाही.
- **VRM** मध्ये skinning आणि morphs CPU वर मोजले जातात आणि प्रत्येक फ्रेमला LowLevelMesh मध्ये लिहिले जातात. खूप जास्त वर्टेक्स असलेल्या मॉडेलसाठी Release बिल्ड वापरा.
- **चेहरा ट्रॅकिंग** ARKit (TrueDepth) वापरते, त्यामुळे Mac आणि Vision Pro वर उपलब्ध नाही. ओठांचे लँडमार्क नसल्याने तोंड उघडणे फक्त `jawOpen` वरून ठरते.
- **visionOS**: VRM विंडोमध्ये सुमारे 0.36 m उंच असतो.

## परवाना

- कोड: LivLiv Player प्रमाणेच Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`).
- समाविष्ट पात्रे: त्यांना Apache परवाना **लागू होत नाही**. फक्त अव्यावसायिक वापर, श्रेयासह. Kujira आणि Kujira Q CC BY-NC-SA 4.0 अंतर्गत आहेत, आणि Pen साठी कोणताही हक्क दिलेला नाही. वितरणापूर्वी ॲपमधील “परवाने आणि ट्रेडमार्क” वाचा.
- LivLiv नाव आणि लोगो कोणत्याही परवान्यात समाविष्ट नाहीत.
