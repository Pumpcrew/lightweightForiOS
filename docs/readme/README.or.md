# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · **ଓଡ଼ିଆ** · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

ଏହି ପ୍ରୋଜେକ୍ଟ ୱେବ ପାଇଁ ତିଆରି 2.5D ଚରିତ୍ର ପ୍ଲେୟାର [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2)କୁ **iOS, macOS ଓ visionOS ପାଇଁ ନେଟିଭ ଆପ**ରେ ପରିଣତ କରେ। ଚରିତ୍ରଗୁଡ଼ିକ **Metal** ଦ୍ୱାରା, ଏବଂ VRM ଅବତାର ଏହି ପ୍ରୋଜେକ୍ଟ ପାଇଁ **RealityKit** ଉପରେ ଲେଖାଯାଇଥିବା glTF/VRM ଲୋଡର ଦ୍ୱାରା ଅଙ୍କାଯାଏ।

## ଆବଶ୍ୟକତା

- iOS 18, macOS 15 କିମ୍ବା visionOS 2 କିମ୍ବା ପରବର୍ତ୍ତୀ (Xcode 16 କିମ୍ବା ପରବର୍ତ୍ତୀ, Swift 6 ଟୁଲଚେନ)
- କୌଣସି ବାହ୍ୟ ନିର୍ଭରତା ନାହିଁ। ଆପର ଲଜିକ ଏକ ସ୍ଥାନୀୟ Swift ପ୍ୟାକେଜ (`Packages/LivLivKit`)ରେ ଅଛି।

## ବିଲ୍ଡ

1. Xcode ରେ `livlivIOSPlayer.xcodeproj` ଖୋଲନ୍ତୁ।
2. Signing & Capabilities ରେ ନିଜ Team ବାଛନ୍ତୁ, ଆବଶ୍ୟକ ହେଲେ ବଣ୍ଡଲ ଆଇଡେଣ୍ଟିଫାୟର ବଦଳାନ୍ତୁ।
3. ରନ ଗନ୍ତବ୍ୟ ଭାବେ iPhone କିମ୍ବା iPad (ଡିଭାଇସ କିମ୍ବା ସିମୁଲେଟର), My Mac କିମ୍ବା Apple Vision Pro ବାଛି Run (⌘R) ଦବାନ୍ତୁ।

`LivLivCore` Debug ରେ ମଧ୍ୟ `-O` ସହ ବିଲ୍ଡ ହୁଏ, କାରଣ ରିଗ ପ୍ରତି ଫ୍ରେମରେ ହଜାର ହଜାର ଭର୍ଟେକ୍ସ ଘୁଞ୍ଚାଏ (k01: `-Onone` ରେ ପ୍ରତି ଫ୍ରେମ ପ୍ରାୟ 17 ms, `-O` ରେ ପ୍ରାୟ 2 ms)।

## ବୈଶିଷ୍ଟ୍ୟ

- **ଚରିତ୍ର**: 21ଟି ଅନ୍ତର୍ଭୁକ୍ତ ଚରିତ୍ର
- **ଇମ୍ପୋର୍ଟ କରନ୍ତୁ**: ଆପର Documents ଫୋଲ୍ଡରରେ ରଖିଥିବା ଫୋଲ୍ଡର କିମ୍ବା ଫାଇଲ ବାଛନ୍ତୁ। ଆପ ପ୍ରଥମେ ଯାଞ୍ଚ କରେ ଯେ ଏହା ଖୋଲିପାରିବ, ତାପରେ ଲୋଡ କରେ। ନ ପାରିଲେ, ଏକ ସତର୍କତା କାରଣକୁ ବାଛି ଓ କପି କରିହେବା ଭଳି ଟେକ୍ସଟ ଭ୍ୟୁରେ ଦେଖାଏ।
- Documents ଫୋଲ୍ଡର: iPhone, iPad ଓ Vision Pro ରେ ଫାଇଲ୍ସ › ମୋ iPhone ରେ › livlivIOSPlayer; Mac ରେ ଇମ୍ପୋର୍ଟ କରନ୍ତୁ ର “Finder ରେ Documents ଫୋଲ୍ଡର ଖୋଲନ୍ତୁ”। “ଅନ୍ୟ ସ୍ଥାନରୁ ବାଛନ୍ତୁ…” ଅନ୍ୟ ସ୍ଥାନର ଫୋଲ୍ଡର କିମ୍ବା ଫାଇଲ ଖୋଲେ।
- ଭାବଭଙ୍ଗୀ, କ୍ରିୟା ଓ ଢୁଳାଇବା। ଚରିତ୍ର ପଏଣ୍ଟରକୁ ଅନୁସରଣ କରେ, ଦୋହଲୁଥିବା ଅଂଶ ଛୁଇଁଲେ ଡେଇଁଉଠେ, ଏବଂ ପିଞ୍ଚ କରି ଜୁମ କରିହେବ।
- ମାଇକ୍ରୋଫୋନ କିମ୍ବା ଅଡିଓ ଫାଇଲରୁ **ଲିପ ସିଙ୍କ**, ଏବଂ TrueDepth ଥିବା iPhone କିମ୍ବା iPad ରେ **ମୁହଁ ଟ୍ରାକିଂ**
- **ସେଟିଂସ**: ଗତି, ରିଜୋଲ୍ୟୁସନ, ମୁହଁ ଟ୍ରାକିଂ, ଏବଂ ଓପନ ସୋର୍ସ ଲାଇସେନ୍ସ › “ଲାଇସେନ୍ସ ଓ ଟ୍ରେଡମାର୍କ”

## ସମର୍ଥିତ ଫର୍ମାଟ

- LivLiv ମଡେଲ ଫୋଲ୍ଡର (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender ପାଇଁ VRM Add-on ଦ୍ୱାରା ଏକ୍ସପୋର୍ଟ ହୋଇଥିବା ଫାଇଲ ସହିତ
- PNGTuber ଫୋଲ୍ଡର: `closed.png`, `open.png` (ଇଚ୍ଛାଧୀନ: `blink.png`, `blink-open.png`, `name.txt`)

ଯେଉଁ ଫାଇଲ ଚଳାଯାଇପାରିବ ନାହିଁ (ମେସ ନଥିବା VRM, Draco / Meshopt / KTX2 କମ୍ପ୍ରେସନ, ଅତି ବଡ଼ ଛବି) ତାହାକୁ କାରଣ ସହ ପ୍ରତ୍ୟାଖ୍ୟାନ କରାଯାଏ।

## ସ୍ଥାନୀୟକରଣ

- ଆପର ଲେଖା 50ଟି ଭାଷାରେ String Catalog (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`)ରେ ଅଛି। ବିକାଶ ଭାଷା ଇଂରାଜୀ, ଏବଂ ଇଂରାଜୀର ଆଞ୍ଚଳିକ ରୂପଗୁଡ଼ିକ ମଧ୍ୟ ତାହା ବ୍ୟବହାର କରନ୍ତି।
- “ଲାଇସେନ୍ସ ଓ ଟ୍ରେଡମାର୍କ” ଡକ୍ୟୁମେଣ୍ଟ କୋରିଆନ ଡିଭାଇସରେ କୋରିଆନରେ ଏବଂ ଅନ୍ୟତ୍ର ଇଂରାଜୀରେ ଦେଖାଯାଏ। ଚରିତ୍ରଙ୍କ ନାମ, ଶ୍ରେୟ ଓ ଲାଇସେନ୍ସର ମୂଳ ପାଠ ଅନୁବାଦ ହୁଏ ନାହିଁ।
- ଏହି README ସେହି ଭାଷାଗୁଡ଼ିକରେ ଉପଲବ୍ଧ (ଉପର ଲିଙ୍କ)। ଅନୁବାଦଗୁଡ଼ିକୁ ଏପର୍ଯ୍ୟନ୍ତ ମାତୃଭାଷୀମାନେ ସମୀକ୍ଷା କରିନାହାନ୍ତି, ତେଣୁ ସଂଶୋଧନ ସ୍ୱାଗତଯୋଗ୍ୟ।

## ପ୍ରୋଜେକ୍ଟ ଗଠନ

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

## ମୂଳ → ପୋର୍ଟ

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

## ପରୀକ୍ଷା

```sh
cd Packages/LivLivKit
swift test
```

Linux ରେ ଯାଞ୍ଚ ହୋଇଛି: 21ଟି ଅନ୍ତର୍ଭୁକ୍ତ ଚରିତ୍ର ପଢ଼ିବା ଓ ପ୍ରତ୍ୟେକର 240 ଫ୍ରେମ ଚଳାଇବା (ଭାବଭଙ୍ଗୀ, କ୍ରିୟା, ପାଟି, ଆଇରିସ ଷ୍ଟେନସିଲ), keyforms, ଶିକୁଳିର ଡେଇଁବା, ZIP, ଲିପ ସିଙ୍କ ବିଶ୍ଳେଷଣ, VRM 0.x / 1.0 ପଢ଼ିବା ଓ ପ୍ରତ୍ୟାଖ୍ୟାନ, skinning, morphs ଓ spring bones, ଏବଂ Blender ପାଇଁ VRM Add-on ଯାହା ଲେଖେ (ନାମ ଥିବା କିନ୍ତୁ ବ୍ୟବହାର ହୋଇନଥିବା କମ୍ପ୍ରେସନ, `KHR_texture_transform`, samplers)।

## ଜଣାଥିବା ପାର୍ଥକ୍ୟ ଓ ସୀମା

- **MToon**କୁ RealityKit ର ଆଲୋକହୀନ ମ୍ୟାଟେରିଆଲ ଦ୍ୱାରା ଆନୁମାନିକ ଦେଖାଯାଏ (ମୂଳ ରଙ୍ଗ, ଟେକ୍ସଚର, ଆଲଫା ମୋଡ, ଦୁଇ ପାର୍ଶ୍ୱ)। ରିମ ଲାଇଟ ଓ ଛାଇର ସୀମା ନାହିଁ।
- **VRM** ରେ skinning ଓ morphs CPU ରେ ଗଣନା ହୋଇ ପ୍ରତି ଫ୍ରେମ LowLevelMesh ରେ ଲେଖାଯାଏ। ଅତି ଅଧିକ ଭର୍ଟେକ୍ସ ଥିବା ମଡେଲ ପାଇଁ Release ବିଲ୍ଡ ବ୍ୟବହାର କରନ୍ତୁ।
- **ମୁହଁ ଟ୍ରାକିଂ** ARKit (TrueDepth) ବ୍ୟବହାର କରେ, ତେଣୁ Mac ଓ Vision Pro ରେ ଉପଲବ୍ଧ ନୁହେଁ। ଓଠର ଲ୍ୟାଣ୍ଡମାର୍କ ନଥିବାରୁ ପାଟି ଖୋଲିବା କେବଳ `jawOpen` ରୁ ସ୍ଥିର ହୁଏ।
- **visionOS**: VRM ୱିଣ୍ଡୋରେ ପ୍ରାୟ 0.36 m ଉଚ୍ଚ ହୁଏ।

## ଲାଇସେନ୍ସ

- କୋଡ: LivLiv Player ଭଳି Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`)।
- ଅନ୍ତର୍ଭୁକ୍ତ ଚରିତ୍ର: ଏଗୁଡ଼ିକ ଉପରେ Apache ଲାଇସେନ୍ସ **ଲାଗୁ ହୁଏ ନାହିଁ**। କେବଳ ଅଣ-ବ୍ୟବସାୟିକ ବ୍ୟବହାର, ଶ୍ରେୟ ସହ। Kujira ଓ Kujira Q CC BY-NC-SA 4.0 ଅଧୀନରେ, ଏବଂ Pen ପାଇଁ କୌଣସି ଅଧିକାର ଦିଆଯାଇନାହିଁ। ବଣ୍ଟନ ପୂର୍ବରୁ ଆପରେ “ଲାଇସେନ୍ସ ଓ ଟ୍ରେଡମାର୍କ” ପଢ଼ନ୍ତୁ।
- LivLiv ନାମ ଓ ଲୋଗୋ କୌଣସି ଲାଇସେନ୍ସରେ ଅନ୍ତର୍ଭୁକ୍ତ ନୁହେଁ।
