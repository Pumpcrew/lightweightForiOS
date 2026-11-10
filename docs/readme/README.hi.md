# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · **हिन्दी** · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

यह प्रोजेक्ट वेब के लिए बने 2.5D कैरेक्टर प्लेयर [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2) को **iOS, macOS और visionOS के नेटिव ऐप** में बदलता है। कैरेक्टर **Metal** से बनाए जाते हैं, और VRM अवतार इस प्रोजेक्ट के लिए **RealityKit** पर लिखे गए glTF/VRM लोडर से।

## ज़रूरतें

- iOS 18, macOS 15 या visionOS 2 या बाद का (Xcode 16 या बाद का, Swift 6 टूलचेन)
- कोई बाहरी निर्भरता नहीं। ऐप का लॉजिक एक लोकल Swift पैकेज (`Packages/LivLivKit`) में है।

## बिल्ड

1. Xcode में `livlivIOSPlayer.xcodeproj` खोलें।
2. Signing & Capabilities में अपनी Team चुनें, और ज़रूरत हो तो बंडल आइडेंटिफ़ायर बदलें।
3. रन डेस्टिनेशन के रूप में iPhone या iPad (डिवाइस या सिम्युलेटर), My Mac या Apple Vision Pro चुनें, फिर Run (⌘R) दबाएँ।

`LivLivCore` को Debug में भी `-O` के साथ बिल्ड किया जाता है, क्योंकि रिग हर फ़्रेम में दसियों हज़ार वर्टेक्स हिलाता है (k01: `-Onone` पर प्रति फ़्रेम लगभग 17 ms, `-O` पर लगभग 2 ms)।

## सुविधाएँ

- **कैरेक्टर**: 21 शामिल कैरेक्टर
- **इंपोर्ट करें**: वह फ़ोल्डर या फ़ाइल चुनें जो आपने ऐप के Documents फ़ोल्डर में रखी है। ऐप पहले जाँचता है कि वह उसे खोल सकता है, फिर लोड करता है। न खोल पाए तो एक अलर्ट कारण को ऐसे टेक्स्ट व्यू में दिखाता है जिसे चुना और कॉपी किया जा सकता है।
- Documents फ़ोल्डर: iPhone, iPad और Vision Pro पर फ़ाइल्स › मेरे iPhone पर › livlivIOSPlayer; Mac पर इंपोर्ट करें में “Finder में Documents फ़ोल्डर खोलें”। “किसी दूसरी जगह से चुनें…” किसी दूसरी जगह का फ़ोल्डर या फ़ाइल खोलता है।
- हाव-भाव, ऐक्शन और झपकी। कैरेक्टर पॉइंटर के पीछे देखता है, झूलने वाले हिस्से छूने पर उछलते हैं, और पिंच करके ज़ूम कर सकते हैं।
- माइक्रोफ़ोन या ऑडियो फ़ाइल से **लिप सिंक**, और TrueDepth वाले iPhone या iPad पर **चेहरा ट्रैकिंग**
- **सेटिंग्ज़**: गति, रिज़ॉल्यूशन, चेहरा ट्रैकिंग, और ओपन सोर्स लाइसेंस › “लाइसेंस और ट्रेडमार्क”

## समर्थित फ़ॉर्मैट

- LivLiv मॉडल फ़ोल्डर (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender के VRM Add-on से एक्सपोर्ट की गई फ़ाइलें भी
- PNGTuber फ़ोल्डर: `closed.png`, `open.png` (वैकल्पिक: `blink.png`, `blink-open.png`, `name.txt`)

जो फ़ाइल चलाई नहीं जा सकती (बिना मेश का VRM, Draco / Meshopt / KTX2 कंप्रेशन, बहुत बड़ी इमेज), उसे कारण बताकर अस्वीकार किया जाता है।

## स्थानीयकरण

- ऐप का टेक्स्ट 50 भाषाओं में String Catalogs (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`) में है। डेवलपमेंट भाषा अंग्रेज़ी है, और अंग्रेज़ी के क्षेत्रीय रूप भी उसी का उपयोग करते हैं।
- “लाइसेंस और ट्रेडमार्क” दस्तावेज़ कोरियाई डिवाइस पर कोरियाई में और बाकी जगह अंग्रेज़ी में दिखता है। कैरेक्टर के नाम, श्रेय और लाइसेंस के मूल पाठ का अनुवाद नहीं किया जाता।
- यह README इन्हीं भाषाओं में उपलब्ध है (ऊपर लिंक)। अनुवादों की अभी मूल भाषियों ने समीक्षा नहीं की है, इसलिए सुधार का स्वागत है।

## प्रोजेक्ट की संरचना

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

## मूल → पोर्ट

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

## टेस्ट

```sh
cd Packages/LivLivKit
swift test
```

Linux पर जाँचा गया: 21 शामिल कैरेक्टर पढ़ना और हर एक के 240 फ़्रेम चलाना (हाव-भाव, ऐक्शन, मुँह, आइरिस स्टेंसिल), keyforms, चेन का उछलना, ZIP, लिप सिंक विश्लेषण, VRM 0.x / 1.0 पढ़ना और अस्वीकार करना, skinning, morphs और spring bones, और Blender का VRM Add-on जो लिखता है (नाम दिया गया पर उपयोग न हुआ कंप्रेशन, `KHR_texture_transform`, samplers)।

## ज्ञात अंतर और सीमाएँ

- **MToon** को RealityKit के बिना रोशनी वाले मटीरियल से अनुमानित किया जाता है (बेस कलर, टेक्सचर, अल्फ़ा मोड, दोनों तरफ़)। रिम लाइट और छाया की सीमा नहीं है।
- **VRM** में skinning और morphs CPU पर गिने जाते हैं और हर फ़्रेम LowLevelMesh में लिखे जाते हैं। बहुत ज़्यादा वर्टेक्स वाले मॉडल के लिए Release बिल्ड इस्तेमाल करें।
- **चेहरा ट्रैकिंग** ARKit (TrueDepth) का उपयोग करती है, इसलिए Mac और Vision Pro पर उपलब्ध नहीं है। होंठों के लैंडमार्क न होने से मुँह खुलना केवल `jawOpen` से तय होता है।
- **visionOS**: VRM विंडो में लगभग 0.36 m ऊँचा होता है।

## लाइसेंस

- कोड: LivLiv Player जैसा ही Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`)।
- शामिल कैरेक्टर: इन पर Apache लाइसेंस **लागू नहीं** होता। केवल गैर-व्यावसायिक उपयोग, श्रेय के साथ। Kujira और Kujira Q का लाइसेंस CC BY-NC-SA 4.0 है, और Pen के लिए कोई अधिकार नहीं दिया गया। वितरित करने से पहले ऐप में “लाइसेंस और ट्रेडमार्क” पढ़ें।
- LivLiv नाम और लोगो किसी लाइसेंस में शामिल नहीं हैं।
