# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · **தமிழ்** · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

இந்தத் திட்டம் இணையத்திற்கான 2.5D கதாபாத்திர பிளேயர் [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2) ஐ **iOS, macOS, visionOS க்கான நேட்டிவ் ஆப்ஸாக** மாற்றுகிறது. கதாபாத்திரங்கள் **Metal** மூலமும், VRM அவதாரங்கள் இந்தத் திட்டத்திற்காக **RealityKit** மீது எழுதப்பட்ட glTF/VRM லோடர் மூலமும் வரையப்படுகின்றன.

## தேவைகள்

- iOS 18, macOS 15 அல்லது visionOS 2 அல்லது அதற்குப் பிந்தையவை (Xcode 16 அல்லது பிந்தையது, Swift 6 டூல்செயின்)
- வெளிச் சார்புகள் இல்லை. ஆப்ஸின் லாஜிக் ஒரு உள்ளூர் Swift தொகுப்பில் (`Packages/LivLivKit`) உள்ளது.

## பில்ட்

1. Xcode இல் `livlivIOSPlayer.xcodeproj` ஐத் திறக்கவும்.
2. Signing & Capabilities இல் உங்கள் Team ஐத் தேர்ந்தெடுத்து, தேவைப்பட்டால் பண்டில் அடையாளங்காட்டியை மாற்றவும்.
3. இயக்க இலக்காக iPhone அல்லது iPad (சாதனம் அல்லது சிமுலேட்டர்), My Mac அல்லது Apple Vision Pro ஐத் தேர்ந்தெடுத்து Run (⌘R) ஐ அழுத்தவும்.

`LivLivCore` Debug இலும் `-O` உடன் பில்ட் செய்யப்படுகிறது, ஏனெனில் ரிக் ஒவ்வொரு ஃப்ரேமிலும் பல்லாயிரம் வெர்டெக்ஸ்களை நகர்த்துகிறது (k01: `-Onone` இல் ஒரு ஃப்ரேமுக்கு சுமார் 17 ms, `-O` இல் சுமார் 2 ms).

## அம்சங்கள்

- **கதாபாத்திரங்கள்**: சேர்க்கப்பட்ட 21 கதாபாத்திரங்கள்
- **இறக்கு**: ஆப்ஸின் Documents கோப்புறையில் நீங்கள் வைத்த கோப்புறை அல்லது கோப்பைத் தேர்ந்தெடுக்கவும். ஆப்ஸ் முதலில் அதைத் திறக்க முடியுமா எனச் சரிபார்த்து, பிறகு ஏற்றுகிறது. முடியாவிட்டால், தேர்ந்தெடுத்து நகலெடுக்கக்கூடிய உரைக் காட்சியில் ஒரு எச்சரிக்கை காரணத்தைக் காட்டுகிறது.
- Documents கோப்புறை: iPhone, iPad, Vision Pro இல் கோப்புகள் › எனது iPhone இல் › livlivIOSPlayer; Mac இல் இறக்கு இல் உள்ள “Finder இல் Documents கோப்புறையைத் திற”. “வேறு இடத்திலிருந்து தேர்ந்தெடு…” வேறு இடத்திலுள்ள கோப்புறை அல்லது கோப்பைத் திறக்கிறது.
- முகபாவங்கள், செயல்கள், கண்ணயர்வு. கதாபாத்திரம் சுட்டியைப் பின்தொடர்கிறது, ஆடும் பாகங்கள் தொட்டால் துள்ளுகின்றன, பிஞ்ச் செய்து பெரிதாக்கலாம்.
- மைக்ரோஃபோன் அல்லது ஆடியோ கோப்பிலிருந்து **லிப் சிங்க்**, TrueDepth உள்ள iPhone அல்லது iPad இல் **முக டிராக்கிங்**
- **அமைப்புகள்**: அசைவு, தெளிவுத்திறன், முக டிராக்கிங், மற்றும் திறந்த மூல உரிமங்கள் › “உரிமங்களும் வர்த்தக முத்திரைகளும்”

## ஆதரிக்கப்படும் வடிவங்கள்

- LivLiv மாதிரிக் கோப்புறை (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender க்கான VRM Add-on மூலம் ஏற்றுமதி செய்த கோப்புகள் உட்பட
- PNGTuber கோப்புறை: `closed.png`, `open.png` (விருப்பம்: `blink.png`, `blink-open.png`, `name.txt`)

இயக்க முடியாத கோப்பு (மெஷ் இல்லாத VRM, Draco / Meshopt / KTX2 சுருக்கம், மிகப் பெரிய படங்கள்) காரணத்துடன் நிராகரிக்கப்படும்.

## உள்ளூர்மயமாக்கல்

- ஆப்ஸின் உரை 50 மொழிகளில் String Catalog களில் (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`) உள்ளது. மேம்பாட்டு மொழி ஆங்கிலம்; ஆங்கிலத்தின் பிராந்திய வடிவங்களும் அதையே பயன்படுத்துகின்றன.
- “உரிமங்களும் வர்த்தக முத்திரைகளும்” ஆவணம் கொரிய சாதனங்களில் கொரிய மொழியிலும் மற்ற இடங்களில் ஆங்கிலத்திலும் தோன்றும். கதாபாத்திரப் பெயர்கள், நன்றிக்குறிப்புகள், உரிமங்களின் மூல உரை மொழிபெயர்க்கப்படுவதில்லை.
- இந்த README அதே மொழிகளில் கிடைக்கிறது (மேலே இணைப்புகள்). மொழிபெயர்ப்புகளைத் தாய்மொழியாளர்கள் இன்னும் சரிபார்க்கவில்லை, எனவே திருத்தங்கள் வரவேற்கப்படுகின்றன.

## திட்ட அமைப்பு

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

## மூலம் → மாற்றம்

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

## சோதனைகள்

```sh
cd Packages/LivLivKit
swift test
```

Linux இல் சரிபார்க்கப்பட்டது: சேர்க்கப்பட்ட 21 கதாபாத்திரங்களைப் படித்தல், ஒவ்வொன்றின் 240 ஃப்ரேம்களை இயக்குதல் (முகபாவங்கள், செயல்கள், வாய், கருவிழி ஸ்டென்சில்), keyforms, சங்கிலிகளின் துள்ளல், ZIP, லிப் சிங்க் பகுப்பாய்வு, VRM 0.x / 1.0 படித்தல் மற்றும் நிராகரித்தல், skinning, morphs, spring bones, மற்றும் Blender க்கான VRM Add-on எழுதுபவை (பெயர் உள்ள ஆனால் பயன்படுத்தப்படாத சுருக்கம், `KHR_texture_transform`, samplers).

## அறியப்பட்ட வேறுபாடுகள் மற்றும் வரம்புகள்

- **MToon** RealityKit இன் ஒளியற்ற மெட்டீரியல் மூலம் தோராயமாக்கப்படுகிறது (அடிப்படை நிறம், டெக்ஸ்சர், ஆல்ஃபா பயன்முறை, இரு பக்கம்). விளிம்பு ஒளியும் நிழல் எல்லையும் இல்லை.
- **VRM** இல் skinning, morphs ஆகியவை CPU இல் கணக்கிடப்பட்டு ஒவ்வொரு ஃப்ரேமிலும் LowLevelMesh இல் எழுதப்படுகின்றன. மிக அதிக வெர்டெக்ஸ் உள்ள மாதிரிகளுக்கு Release பில்டைப் பயன்படுத்தவும்.
- **முக டிராக்கிங்** ARKit (TrueDepth) ஐப் பயன்படுத்துவதால் Mac, Vision Pro இல் கிடைக்காது. உதட்டுக் குறிப்புப் புள்ளிகள் இல்லாததால் வாய் திறப்பு `jawOpen` மட்டுமே தீர்மானிக்கிறது.
- **visionOS**: VRM சாளரத்தில் சுமார் 0.36 m உயரத்தில் நிற்கிறது.

## உரிமம்

- குறியீடு: LivLiv Player போலவே Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`).
- சேர்க்கப்பட்ட கதாபாத்திரங்கள்: இவற்றுக்கு Apache உரிமம் **பொருந்தாது**. வணிக நோக்கமற்ற பயன்பாட்டுக்கு மட்டும், நன்றிக்குறிப்புடன். Kujira, Kujira Q ஆகியவை CC BY-NC-SA 4.0 இல் உள்ளன; Pen க்கு எந்த உரிமையும் வழங்கப்படவில்லை. விநியோகிக்கும் முன் ஆப்ஸில் உள்ள “உரிமங்களும் வர்த்தக முத்திரைகளும்” ஐப் படிக்கவும்.
- LivLiv பெயரும் லோகோவும் எந்த உரிமத்திலும் அடங்காது.
