# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · **ગુજરાતી** · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

આ પ્રોજેક્ટ વેબ માટેના 2.5D પાત્ર પ્લેયર [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2)ને **iOS, macOS અને visionOSની નેટિવ ઍપ**માં ફેરવે છે. પાત્રો **Metal** વડે દોરાય છે, અને VRM અવતાર આ પ્રોજેક્ટ માટે **RealityKit** પર લખાયેલા glTF/VRM લોડર વડે.

## જરૂરિયાતો

- iOS 18, macOS 15 અથવા visionOS 2 કે પછીનું (Xcode 16 કે પછીનું, Swift 6 ટૂલચેન)
- કોઈ બાહ્ય નિર્ભરતા નથી. ઍપનું લૉજિક સ્થાનિક Swift પૅકેજ (`Packages/LivLivKit`)માં છે.

## બિલ્ડ

1. Xcodeમાં `livlivIOSPlayer.xcodeproj` ખોલો.
2. Signing & Capabilitiesમાં તમારી Team પસંદ કરો, અને જરૂર હોય તો બંડલ આઇડેન્ટિફાયર બદલો.
3. રન ગંતવ્ય તરીકે iPhone કે iPad (ડિવાઇસ કે સિમ્યુલેટર), My Mac કે Apple Vision Pro પસંદ કરી Run (⌘R) દબાવો.

`LivLivCore` Debugમાં પણ `-O` સાથે બિલ્ડ થાય છે, કારણ કે રિગ દરેક ફ્રેમમાં હજારો વર્ટેક્સ ખસેડે છે (k01: `-Onone`માં ફ્રેમ દીઠ આશરે 17 ms, `-O`માં આશરે 2 ms).

## સુવિધાઓ

- **પાત્રો**: 21 સમાવિષ્ટ પાત્રો
- **ઇમ્પોર્ટ કરો**: ઍપના Documents ફોલ્ડરમાં મૂકેલું ફોલ્ડર કે ફાઇલ પસંદ કરો. ઍપ પહેલાં તપાસે છે કે તે ખોલી શકે છે, પછી લોડ કરે છે. ન ખોલી શકે તો ચેતવણી કારણને પસંદ અને કૉપિ કરી શકાય તેવા ટેક્સ્ટ વ્યૂમાં બતાવે છે.
- Documents ફોલ્ડર: iPhone, iPad અને Vision Pro પર ફાઇલ્સ › મારા iPhone પર › livlivIOSPlayer; Mac પર ઇમ્પોર્ટ કરોમાં “Finderમાં Documents ફોલ્ડર ખોલો”. “બીજા સ્થાનેથી પસંદ કરો…” બીજી જગ્યાનું ફોલ્ડર કે ફાઇલ ખોલે છે.
- હાવભાવ, ક્રિયાઓ અને ઝોકું. પાત્ર પોઇન્ટરને અનુસરે છે, ઝૂલતા ભાગો સ્પર્શ કરતાં ઊછળે છે, અને પિંચ કરીને ઝૂમ કરી શકાય છે.
- માઇક્રોફોન કે ઓડિયો ફાઇલથી **લિપ સિંક**, અને TrueDepth ધરાવતા iPhone કે iPad પર **ચહેરો ટ્રેકિંગ**
- **સેટિંગ્સ**: ગતિ, રિઝોલ્યુશન, ચહેરો ટ્રેકિંગ, અને ઓપન સોર્સ લાઇસન્સ › “લાઇસન્સ અને ટ્રેડમાર્ક”

## સમર્થિત ફોર્મેટ

- LivLiv મૉડલ ફોલ્ડર (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), Blender માટેના VRM Add-on વડે એક્સપોર્ટ કરેલી ફાઇલો સહિત
- PNGTuber ફોલ્ડર: `closed.png`, `open.png` (વૈકલ્પિક: `blink.png`, `blink-open.png`, `name.txt`)

જે ફાઇલ ચલાવી ન શકાય (મેશ વગરનું VRM, Draco / Meshopt / KTX2 કમ્પ્રેશન, ખૂબ મોટી છબીઓ) તેને કારણ સાથે નકારવામાં આવે છે.

## સ્થાનિકીકરણ

- ઍપનું લખાણ 50 ભાષાઓમાં String Catalogs (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`)માં છે. વિકાસ ભાષા અંગ્રેજી છે, અને અંગ્રેજીના પ્રાદેશિક રૂપો પણ તે જ વાપરે છે.
- “લાઇસન્સ અને ટ્રેડમાર્ક” દસ્તાવેજ કોરિયન ડિવાઇસ પર કોરિયનમાં અને બીજે અંગ્રેજીમાં દેખાય છે. પાત્રોનાં નામ, શ્રેય અને લાઇસન્સનાં મૂળ લખાણનો અનુવાદ થતો નથી.
- આ README આ જ ભાષાઓમાં ઉપલબ્ધ છે (ઉપર લિંક). અનુવાદોની હજી માતૃભાષીઓએ સમીક્ષા કરી નથી, તેથી સુધારાનું સ્વાગત છે.

## પ્રોજેક્ટની રચના

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

## મૂળ → પોર્ટ

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

## ટેસ્ટ

```sh
cd Packages/LivLivKit
swift test
```

Linux પર ચકાસ્યું: 21 સમાવિષ્ટ પાત્રો વાંચવાં અને દરેકની 240 ફ્રેમ ચલાવવી (હાવભાવ, ક્રિયાઓ, મોં, આઇરિસ સ્ટેન્સિલ), keyforms, સાંકળોનું ઊછળવું, ZIP, લિપ સિંક વિશ્લેષણ, VRM 0.x / 1.0 વાંચવું અને નકારવું, skinning, morphs અને spring bones, અને Blender માટેનું VRM Add-on જે લખે છે તે (નામ છે પણ વપરાયું નથી તેવું કમ્પ્રેશન, `KHR_texture_transform`, samplers).

## જાણીતા તફાવતો અને મર્યાદાઓ

- **MToon**ને RealityKitના પ્રકાશ વિનાના મટીરિયલથી અંદાજવામાં આવે છે (મૂળ રંગ, ટેક્સ્ચર, આલ્ફા મોડ, બંને બાજુ). રિમ લાઇટ અને છાયાની સીમા નથી.
- **VRM**માં skinning અને morphs CPU પર ગણાય છે અને દરેક ફ્રેમે LowLevelMeshમાં લખાય છે. ઘણા વધારે વર્ટેક્સવાળા મૉડલ માટે Release બિલ્ડ વાપરો.
- **ચહેરો ટ્રેકિંગ** ARKit (TrueDepth) વાપરે છે, તેથી Mac અને Vision Pro પર ઉપલબ્ધ નથી. હોઠના લૅન્ડમાર્ક ન હોવાથી મોં ખૂલવું ફક્ત `jawOpen`થી નક્કી થાય છે.
- **visionOS**: VRM વિન્ડોમાં આશરે 0.36 m ઊંચું હોય છે.

## લાઇસન્સ

- કોડ: LivLiv Player જેવું જ Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`).
- સમાવિષ્ટ પાત્રો: તેમને Apache લાઇસન્સ **લાગુ પડતું નથી**. ફક્ત બિન-વ્યાવસાયિક ઉપયોગ, શ્રેય સાથે. Kujira અને Kujira Q CC BY-NC-SA 4.0 હેઠળ છે, અને Pen માટે કોઈ અધિકાર અપાયો નથી. વિતરણ પહેલાં ઍપમાં “લાઇસન્સ અને ટ્રેડમાર્ક” વાંચો.
- LivLiv નામ અને લોગો કોઈ લાઇસન્સમાં સમાવિષ્ટ નથી.
