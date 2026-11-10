# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · **Қазақ тілі** · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Бұл жоба веб үшін жасалған 2.5D кейіпкер ойнатқышы [LivLiv Player](https://github.com/livliv-dev/player) (TypeScript/WebGL2) бағдарламасын **iOS, macOS және visionOS үшін нативті қолданбаға** көшіреді. Кейіпкерлер **Metal** арқылы, ал VRM аватарлары осы жоба үшін **RealityKit** негізінде жазылған glTF/VRM жүктегішімен салынады.

## Талаптар

- iOS 18, macOS 15 немесе visionOS 2 не одан жаңа (Xcode 16 не одан жаңа, Swift 6 құралдары)
- Сыртқы тәуелділіктер жоқ. Қолданба логикасы жергілікті Swift бумасында (`Packages/LivLivKit`).

## Құрастыру

1. `livlivIOSPlayer.xcodeproj` файлын Xcode ішінде ашыңыз.
2. Signing & Capabilities бөлімінде өз Team-іңізді таңдаңыз, қажет болса бума идентификаторын өзгертіңіз.
3. Мақсат ретінде iPhone не iPad (құрылғы не симулятор), My Mac немесе Apple Vision Pro таңдап, Run (⌘R) басыңыз.

`LivLivCore` Debug режимінде де `-O` арқылы құрастырылады, себебі риг әр кадрда он мыңдаған төбені жылжытады (k01: `-Onone` кезінде кадрына шамамен 17 ms, `-O` кезінде шамамен 2 ms).

## Мүмкіндіктер

- **Кейіпкерлер**: 21 ендірілген кейіпкер
- **Импорттау**: қолданбаның Documents қалтасына салған қалтаны не файлды таңдаңыз. Қолданба алдымен оны аша алатынын тексеріп, содан кейін жүктейді. Аша алмаса, ескерту себебін белгілеуге және көшіруге болатын мәтін көрінісінде көрсетеді.
- Documents қалтасы: iPhone, iPad және Vision Pro құрылғыларында «Файлдар» › «Менің iPhone құрылғымда» › livlivIOSPlayer; Mac жүйесінде «Импорттау» ішіндегі «Documents қалтасын Finder ішінде ашу». «Басқа орыннан таңдау…» басқа жердегі қалтаны не файлды ашады.
- Мимика, әрекеттер және мүлгу. Кейіпкер көрсеткішке қарайды, тербелетін бөліктер түрткенде серпіледі, ал шымшу арқылы үлкейтуге болады.
- Микрофоннан не аудиофайлдан **ерін синхрондау** және TrueDepth бар iPhone не iPad құрылғысында **бетті бақылау**
- **Параметрлер**: қозғалыс, ажыратымдылық, бетті бақылау және Ашық бастапқы код лицензиялары › «Лицензиялар және сауда белгілері»

## Қолдау көрсетілетін пішімдер

- LivLiv моделі қалтасы (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), соның ішінде Blender үшін VRM Add-on экспорттаған файлдар
- PNGTuber қалтасы: `closed.png`, `open.png` (міндетті емес: `blink.png`, `blink-open.png`, `name.txt`)

Ойнатуға болмайтын файл (торы жоқ VRM, Draco / Meshopt / KTX2 сығымдау, тым үлкен суреттер) себебі көрсетіліп қабылданбайды.

## Локализация

- Қолданба мәтіндері 50 тілде, жолдар каталогтарында (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Әзірлеу тілі — ағылшын тілі, оны ағылшын тілінің аймақтық нұсқалары да пайдаланады.
- «Лицензиялар және сауда белгілері» құжаты корей тіліндегі құрылғыларда корей тілінде, басқаларында ағылшын тілінде көрсетіледі. Кейіпкер аттары, авторлықты көрсету және лицензиялардың түпнұсқа мәтіндері аударылмайды.
- Бұл README сол тілдерде қолжетімді (жоғарғы сілтемелер). Аудармаларды ана тілінде сөйлейтіндер әлі тексерген жоқ, сондықтан түзетулерге қуаныштымыз.

## Жоба құрылымы

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

## Түпнұсқа → көшірме

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

## Сынақтар

```sh
cd Packages/LivLivKit
swift test
```

Linux жүйесінде тексерілді: 21 ендірілген кейіпкерді оқу және әрқайсысының 240 кадрын ойнату (мимика, әрекеттер, ауыз, көз нұры трафареті), keyforms, тізбектердің серпілуі, ZIP, ерін синхрондауына талдау, VRM 0.x / 1.0 оқу және қабылдамау, скиннинг, морфтар және spring bones, сондай-ақ Blender үшін VRM Add-on жазатын деректер (аты аталған, бірақ пайдаланылмаған сығымдау, `KHR_texture_transform`, сэмплерлер).

## Белгілі айырмашылықтар мен шектеулер

- **MToon** RealityKit жарықсыз материалымен шамаланады (негізгі түс, текстура, альфа режимі, екі жақтылық). Жиек жарығы мен көлеңке шекарасы жоқ.
- **VRM** үшін скиннинг пен морфтар CPU-да есептеліп, әр кадрда LowLevelMesh-ке жазылады. Төбелері өте көп модельдер үшін Release құрастыруын пайдаланыңыз.
- **Бетті бақылау** ARKit (TrueDepth) пайдаланады, сондықтан Mac пен Vision Pro құрылғыларында қолжетімсіз. Ерін нүктелері болмағандықтан, ауыздың ашылуы тек `jawOpen` бойынша анықталады.
- **visionOS**: VRM терезеде шамамен 0,36 m биіктікте тұрады.

## Лицензия

- Код: LivLiv Player сияқты Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`).
- Ендірілген кейіпкерлер: Apache лицензиясы оларға **қолданылмайды**. Тек коммерциялық емес пайдалану, авторлықты көрсетумен. Kujira мен Kujira Q — CC BY-NC-SA 4.0, ал Pen үшін ешқандай құқық берілмейді. Таратпас бұрын қолданбадағы «Лицензиялар және сауда белгілері» құжатын оқыңыз.
- LivLiv атауы мен логотипі ешбір лицензияға кірмейді.
