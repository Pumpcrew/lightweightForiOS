# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · **తెలుగు** · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

ఈ ప్రాజెక్ట్ వెబ్ కోసం ఉన్న 2.5D పాత్ర ప్లేయర్ [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2)ను **iOS, macOS, visionOS కోసం నేటివ్ యాప్**గా మారుస్తుంది. పాత్రలు **Metal**తో, VRM అవతార్‌లు ఈ ప్రాజెక్ట్ కోసం **RealityKit**పై రాసిన glTF/VRM లోడర్‌తో గీయబడతాయి.

## అవసరాలు

- iOS 18, macOS 15 లేదా visionOS 2 లేదా తర్వాతి వెర్షన్ (Xcode 16 లేదా తర్వాతిది, Swift 6 టూల్‌చెయిన్)
- బాహ్య డిపెండెన్సీలు లేవు. యాప్ లాజిక్ ఒక లోకల్ Swift ప్యాకేజీ (`Packages/LivLivKit`)లో ఉంది.

## బిల్డ్

1. Xcodeలో `livlivIOSPlayer.xcodeproj` తెరవండి.
2. Signing & Capabilitiesలో మీ Teamను ఎంచుకోండి, అవసరమైతే బండిల్ ఐడెంటిఫైయర్ మార్చండి.
3. రన్ గమ్యంగా iPhone లేదా iPad (పరికరం లేదా సిమ్యులేటర్), My Mac లేదా Apple Vision Pro ఎంచుకుని Run (⌘R) నొక్కండి.

`LivLivCore` Debugలో కూడా `-O`తో బిల్డ్ అవుతుంది, ఎందుకంటే రిగ్ ప్రతి ఫ్రేమ్‌లో పదుల వేల వెర్టెక్స్‌లను కదిలిస్తుంది (k01: `-Onone`లో ఫ్రేమ్‌కు సుమారు 17 ms, `-O`లో సుమారు 2 ms).

## ఫీచర్లు

- **పాత్రలు**: చేర్చిన 21 పాత్రలు
- **దిగుమతి చేయి**: యాప్ Documents ఫోల్డర్‌లో మీరు ఉంచిన ఫోల్డర్ లేదా ఫైల్‌ను ఎంచుకోండి. యాప్ ముందు దాన్ని తెరవగలదో తనిఖీ చేసి, తర్వాత లోడ్ చేస్తుంది. తెరవలేకపోతే, ఎంచుకుని కాపీ చేయగల టెక్స్ట్ వ్యూలో ఒక హెచ్చరిక కారణాన్ని చూపుతుంది.
- Documents ఫోల్డర్: iPhone, iPad, Vision Proలో ఫైల్స్ › నా iPhone లో › livlivIOSPlayer; Macలో దిగుమతి చేయిలోని “Finder లో Documents ఫోల్డర్ తెరువు”. “వేరే స్థానం నుండి ఎంచుకో…” వేరే చోట ఉన్న ఫోల్డర్ లేదా ఫైల్‌ను తెరుస్తుంది.
- హావభావాలు, చర్యలు, కునుకు. పాత్ర పాయింటర్‌ను అనుసరిస్తుంది, ఊగే భాగాలు తాకితే ఎగిరిపడతాయి, పించ్ చేసి జూమ్ చేయవచ్చు.
- మైక్రోఫోన్ లేదా ఆడియో ఫైల్ నుండి **లిప్ సింక్**, TrueDepth ఉన్న iPhone లేదా iPadలో **ముఖ ట్రాకింగ్**
- **సెట్టింగ్‌లు**: కదలిక, రిజల్యూషన్, ముఖ ట్రాకింగ్, మరియు ఓపెన్ సోర్స్ లైసెన్స్‌లు › “లైసెన్స్‌లు మరియు ట్రేడ్‌మార్క్‌లు”

## మద్దతు ఉన్న ఫార్మాట్‌లు

- LivLiv మోడల్ ఫోల్డర్ (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender కోసం VRM Add-onతో ఎగుమతి చేసిన ఫైల్‌లతో సహా
- PNGTuber ఫోల్డర్: `closed.png`, `open.png` (ఐచ్ఛికం: `blink.png`, `blink-open.png`, `name.txt`)

ప్లే చేయలేని ఫైల్ (మెష్ లేని VRM, Draco / Meshopt / KTX2 కంప్రెషన్, చాలా పెద్ద చిత్రాలు) కారణంతో తిరస్కరించబడుతుంది.

## స్థానికీకరణ

- యాప్ టెక్స్ట్ 50 భాషల్లో String Catalogలలో (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`) ఉంది. డెవలప్‌మెంట్ భాష ఇంగ్లీష్; ఇంగ్లీష్ ప్రాంతీయ రూపాలు కూడా దాన్నే వాడతాయి.
- “లైసెన్స్‌లు మరియు ట్రేడ్‌మార్క్‌లు” పత్రం కొరియన్ పరికరాల్లో కొరియన్‌లో, ఇతర చోట్ల ఇంగ్లీష్‌లో కనిపిస్తుంది. పాత్రల పేర్లు, క్రెడిట్‌లు, లైసెన్స్‌ల మూల పాఠం అనువదించబడవు.
- ఈ README ఇవే భాషల్లో అందుబాటులో ఉంది (పైన లింక్‌లు). అనువాదాలను ఇంకా మాతృభాషీయులు సమీక్షించలేదు, కాబట్టి సవరణలకు స్వాగతం.

## ప్రాజెక్ట్ నిర్మాణం

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

## మూలం → పోర్ట్

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

## పరీక్షలు

```sh
cd Packages/LivLivKit
swift test
```

Linuxలో తనిఖీ చేసినవి: చేర్చిన 21 పాత్రలను చదవడం, ప్రతి దాని 240 ఫ్రేమ్‌లను ప్లే చేయడం (హావభావాలు, చర్యలు, నోరు, ఐరిస్ స్టెన్సిల్), keyforms, గొలుసుల ఎగిరిపాటు, ZIP, లిప్ సింక్ విశ్లేషణ, VRM 0.x / 1.0 చదవడం, తిరస్కరించడం, skinning, morphs, spring bones, మరియు Blender కోసం VRM Add-on రాసేవి (పేరు ఉన్నా వాడని కంప్రెషన్, `KHR_texture_transform`, samplers).

## తెలిసిన తేడాలు మరియు పరిమితులు

- **MToon**ను RealityKit కాంతి లేని మెటీరియల్‌తో సుమారుగా చూపిస్తారు (మూల రంగు, టెక్స్చర్, ఆల్ఫా మోడ్, రెండు వైపులు). రిమ్ లైట్, నీడ సరిహద్దు లేవు.
- **VRM**లో skinning, morphs CPUలో లెక్కించి ప్రతి ఫ్రేమ్ LowLevelMeshలో రాయబడతాయి. చాలా ఎక్కువ వెర్టెక్స్‌లు ఉన్న మోడల్‌లకు Release బిల్డ్ వాడండి.
- **ముఖ ట్రాకింగ్** ARKit (TrueDepth) వాడుతుంది, కాబట్టి Mac, Vision Proలో అందుబాటులో లేదు. పెదవుల ల్యాండ్‌మార్క్‌లు లేనందున నోరు తెరవడం `jawOpen` ఒక్కటే నిర్ణయిస్తుంది.
- **visionOS**: VRM విండోలో సుమారు 0.36 m ఎత్తులో ఉంటుంది.

## లైసెన్స్

- కోడ్: LivLiv Player లాగానే Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`).
- చేర్చిన పాత్రలు: వీటికి Apache లైసెన్స్ **వర్తించదు**. వాణిజ్యేతర వినియోగానికి మాత్రమే, క్రెడిట్‌తో. Kujira, Kujira Q CC BY-NC-SA 4.0 కింద ఉన్నాయి, Penకు ఎలాంటి హక్కులూ ఇవ్వలేదు. పంపిణీ చేసే ముందు యాప్‌లోని “లైసెన్స్‌లు మరియు ట్రేడ్‌మార్క్‌లు” చదవండి.
- LivLiv పేరు మరియు లోగో ఏ లైసెన్స్‌లోనూ చేరవు.
