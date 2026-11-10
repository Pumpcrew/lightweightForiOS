# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · **Русский** · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Этот проект переносит [LivLiv Player](https://github.com/livliv-dev/player), веб-плеер 2.5D-персонажей (TypeScript/WebGL2), в **нативное приложение для iOS, macOS и visionOS**. Персонажи рисуются через **Metal**, а аватары VRM — загрузчиком glTF/VRM, написанным для этого проекта поверх **RealityKit**.

## Требования

- iOS 18, macOS 15 или visionOS 2 и новее (Xcode 16 и новее, инструменты Swift 6)
- Внешних зависимостей нет. Логика приложения находится в локальном пакете Swift (`Packages/LivLivKit`).

## Сборка

1. Откройте `livlivIOSPlayer.xcodeproj` в Xcode.
2. В Signing & Capabilities выберите свой Team и при необходимости измените идентификатор пакета.
3. Выберите целевое устройство — iPhone или iPad (устройство или симулятор), My Mac или Apple Vision Pro — и нажмите Run (⌘R).

`LivLivCore` собирается с `-O` даже в Debug, потому что риг в каждом кадре двигает десятки тысяч вершин (k01: около 17 мс на кадр с `-Onone`, около 2 мс с `-O`).

## Возможности

- **Персонажи**: 21 встроенный персонаж
- **Импорт**: выберите папку или файл, которые вы положили в папку Documents приложения. Приложение сначала проверяет, может ли его открыть, а затем загружает. Если не может, предупреждение показывает причину в текстовом поле, которое можно выделить и скопировать.
- Папка Documents: на iPhone, iPad и Vision Pro — «Файлы» › «На iPhone» › livlivIOSPlayer; на Mac — «Открыть папку Documents в Finder» в разделе «Импорт». «Выбрать в другом месте…» открывает папку или файл из другого места.
- Выражения, действия и дремота. Персонаж следит за указателем, качающиеся части пружинят при касании, а щипком можно увеличить изображение.
- **Синхронизация губ** с микрофона или аудиофайла и **отслеживание лица** на iPhone или iPad с TrueDepth
- **Настройки**: движение, разрешение, отслеживание лица и Лицензии открытого ПО › «Лицензии и товарные знаки»

## Поддерживаемые форматы

- Папка модели LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), включая файлы, экспортированные VRM Add-on для Blender
- Папка PNGTuber: `closed.png`, `open.png` (необязательно: `blink.png`, `blink-open.png`, `name.txt`)

Файл, который нельзя воспроизвести (VRM без меша, сжатие Draco / Meshopt / KTX2, слишком большие изображения), отклоняется с указанием причины.

## Локализация

- Тексты приложения есть на 50 языках, в каталогах строк (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Язык разработки — английский; региональные варианты английского используют его.
- Документ «Лицензии и товарные знаки» показывается на корейском на устройствах с корейским языком и на английском на остальных. Имена персонажей, указания авторства и оригинальные тексты лицензий не переводятся.
- Этот README доступен на тех же языках (ссылки вверху). Переводы ещё не проверены носителями языка, поэтому исправления приветствуются.

## Структура проекта

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

## Тесты

```sh
cd Packages/LivLivKit
swift test
```

Проверено на Linux: чтение 21 встроенного персонажа и по 240 кадров каждого (выражения, действия, рот, трафарет радужки), keyforms, пружинящие цепочки, ZIP, анализ для синхронизации губ, чтение и отклонение VRM 0.x / 1.0, скиннинг, морфы и spring bones, а также то, что записывает VRM Add-on для Blender (сжатие указано, но не используется, `KHR_texture_transform`, сэмплеры).

## Известные отличия и ограничения

- **MToon** приближается неосвещённым материалом RealityKit (базовый цвет, текстура, режим альфы, двусторонность). Контурного света и границы тени нет.
- Для **VRM** скиннинг и морфы считаются на CPU и в каждом кадре записываются в LowLevelMesh. Для моделей с очень большим числом вершин используйте сборку Release.
- **Отслеживание лица** использует ARKit (TrueDepth), поэтому недоступно на Mac и Vision Pro. Без точек губ раскрытие рта определяется только по `jawOpen`.
- **visionOS**: VRM в окне имеет высоту около 0,36 м.

## Лицензия

- Код: Apache License 2.0, как у LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Встроенные персонажи: лицензия Apache на них **не** распространяется. Только некоммерческое использование с указанием авторства. Kujira и Kujira Q — CC BY-NC-SA 4.0, а на Pen не предоставляется никаких прав. Перед распространением прочитайте «Лицензии и товарные знаки» в приложении.
- Название и логотип LivLiv не охвачены ни одной лицензией.
