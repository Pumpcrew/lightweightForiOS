# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · **Български** · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Този проект пренася [LivLiv Player](https://github.com/livliv-dev/player), уеб плейър за 2.5D герои (TypeScript/WebGL2), в **нативно приложение за iOS, macOS и visionOS**. Героите се рисуват с **Metal**, а VRM аватарите — със зареждащ модул glTF/VRM, написан за този проект върху **RealityKit**.

## Изисквания

- iOS 18, macOS 15 или visionOS 2 или по-нова версия (Xcode 16 или по-нов, инструменти Swift 6)
- Няма външни зависимости. Логиката на приложението е в локален пакет на Swift (`Packages/LivLivKit`).

## Компилиране

1. Отворете `livlivIOSPlayer.xcodeproj` в Xcode.
2. В Signing & Capabilities изберете своя Team и при нужда сменете идентификатора на пакета.
3. Изберете за цел iPhone или iPad (устройство или симулатор), My Mac или Apple Vision Pro и натиснете Run (⌘R).

`LivLivCore` се компилира с `-O` дори в Debug, защото ригът мести десетки хиляди върха във всеки кадър (k01: около 17 ms на кадър с `-Onone`, около 2 ms с `-O`).

## Функции

- **Герои**: 21 включени героя
- **Импортиране**: изберете папка или файл, които сте поставили в папката Documents на приложението. Приложението първо проверява дали може да ги отвори и после ги зарежда. Ако не може, предупреждение показва причината в текстово поле, което може да се маркира и копира.
- Папка Documents: на iPhone, iPad и Vision Pro — „Файлове“ › „На моя iPhone“ › livlivIOSPlayer; на Mac — „Отвори папката Documents във Finder“ в „Импортиране“. „Избери от друго място…“ отваря папка или файл от друго място.
- Изражения, действия и дрямка. Героят следи показалеца, люлеещите се части пружинират при докосване, а с щипване можете да увеличите.
- **Синхронизация на устните** от микрофона или аудиофайл и **проследяване на лицето** на iPhone или iPad с TrueDepth
- **Настройки**: движение, разделителна способност, проследяване на лицето и Лицензи с отворен код › „Лицензи и търговски марки“

## Поддържани формати

- Папка с модел LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), включително файлове, експортирани с VRM Add-on за Blender
- Папка PNGTuber: `closed.png`, `open.png` (по избор: `blink.png`, `blink-open.png`, `name.txt`)

Файл, който не може да се възпроизведе (VRM без мрежа, компресия Draco / Meshopt / KTX2, твърде големи изображения), се отхвърля с посочване на причината.

## Локализация

- Текстовете на приложението са на 50 езика, в каталози с низове (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Езикът на разработка е английски, който използват и регионалните варианти на английския.
- Документът „Лицензи и търговски марки“ е на корейски на устройства на корейски и на английски на останалите. Имената на героите, посочването на автори и оригиналните текстове на лицензите не се превеждат.
- Този README е на същите езици (връзки отгоре). Преводите още не са прегледани от носители на езика, затова корекциите са добре дошли.

## Структура на проекта

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

## Оригинал → порт

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

## Тестове

```sh
cd Packages/LivLivKit
swift test
```

Проверено на Linux: четене на 21-те включени героя и по 240 кадъра от всеки (изражения, действия, уста, шаблон на ириса), keyforms, пружиниране на вериги, ZIP, анализ за синхронизация на устните, четене и отхвърляне на VRM 0.x / 1.0, скининг, морфове и spring bones, както и това, което записва VRM Add-on за Blender (посочена, но неизползвана компресия, `KHR_texture_transform`, семплери).

## Известни разлики и ограничения

- **MToon** се приближава с неосветения материал на RealityKit (основен цвят, текстура, режим на алфа, двустранност). Няма контурна светлина и граница на сянката.
- При **VRM** скинингът и морфовете се изчисляват на процесора и във всеки кадър се записват в LowLevelMesh. За модели с много голям брой върхове използвайте компилация Release.
- **Проследяването на лицето** използва ARKit (TrueDepth), затова не е налично на Mac и Vision Pro. Без точки за устните отварянето на устата идва само от `jawOpen`.
- **visionOS**: VRM е висок около 0,36 m в прозореца.

## Лиценз

- Код: Apache License 2.0, както при LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Включени герои: лицензът Apache **не** се прилага за тях. Само за нетърговска употреба, с посочване на автора. Kujira и Kujira Q са под CC BY-NC-SA 4.0, а за Pen не се дават никакви права. Преди разпространение прочетете „Лицензи и търговски марки“ в приложението.
- Името и логото LivLiv не са обхванати от никакъв лиценз.
