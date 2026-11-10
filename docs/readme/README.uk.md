# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · **Українська** · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Цей проєкт переносить [LivLiv Player](https://github.com/livliv-dev/player), вебплеєр 2.5D-персонажів (TypeScript/WebGL2), у **нативну програму для iOS, macOS і visionOS**. Персонажі малюються через **Metal**, а аватари VRM — завантажувачем glTF/VRM, написаним для цього проєкту на основі **RealityKit**.

## Вимоги

- iOS 18, macOS 15 або visionOS 2 чи новіші (Xcode 16 чи новіший, інструменти Swift 6)
- Зовнішніх залежностей немає. Логіка програми міститься в локальному пакеті Swift (`Packages/LivLivKit`).

## Збирання

1. Відкрийте `livlivIOSPlayer.xcodeproj` у Xcode.
2. У Signing & Capabilities виберіть свій Team і за потреби змініть ідентифікатор пакета.
3. Виберіть ціль — iPhone або iPad (пристрій чи симулятор), My Mac або Apple Vision Pro — і натисніть Run (⌘R).

`LivLivCore` збирається з `-O` навіть у Debug, бо риг у кожному кадрі рухає десятки тисяч вершин (k01: близько 17 мс на кадр з `-Onone`, близько 2 мс з `-O`).

## Можливості

- **Персонажі**: 21 вбудований персонаж
- **Імпорт**: виберіть папку або файл, які ви поклали в папку Documents програми. Програма спершу перевіряє, чи може їх відкрити, а потім завантажує. Якщо не може, попередження показує причину в текстовому полі, яке можна виділити й скопіювати.
- Папка Documents: на iPhone, iPad і Vision Pro — «Файли» › «На iPhone» › livlivIOSPlayer; на Mac — «Відкрити папку Documents у Finder» у розділі «Імпорт». «Вибрати з іншого місця…» відкриває папку або файл з іншого місця.
- Вирази, дії та дрімота. Персонаж стежить за вказівником, частини, що гойдаються, пружинять від дотику, а щипком можна збільшити зображення.
- **Синхронізація губ** з мікрофона чи аудіофайлу та **відстеження обличчя** на iPhone або iPad із TrueDepth
- **Параметри**: рух, роздільність, відстеження обличчя та Ліцензії відкритого ПЗ › «Ліцензії та торговельні марки»

## Підтримувані формати

- Папка моделі LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), зокрема файли, експортовані VRM Add-on для Blender
- Папка PNGTuber: `closed.png`, `open.png` (необов’язково: `blink.png`, `blink-open.png`, `name.txt`)

Файл, який не можна відтворити (VRM без меша, стиснення Draco / Meshopt / KTX2, завеликі зображення), відхиляється із зазначенням причини.

## Локалізація

- Тексти програми є 50 мовами в каталогах рядків (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Мова розробки — англійська; регіональні варіанти англійської використовують її.
- Документ «Ліцензії та торговельні марки» показується корейською на пристроях із корейською мовою та англійською на решті. Імена персонажів, зазначення авторства й оригінальні тексти ліцензій не перекладаються.
- Цей README доступний тими самими мовами (посилання вгорі). Переклади ще не перевірили носії мови, тож виправлення вітаються.

## Структура проєкту

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

## Оригінал → порт

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

## Тести

```sh
cd Packages/LivLivKit
swift test
```

Перевірено в Linux: читання 21 вбудованого персонажа й по 240 кадрів кожного (вирази, дії, рот, трафарет райдужки), keyforms, пружні ланцюжки, ZIP, аналіз для синхронізації губ, читання й відхилення VRM 0.x / 1.0, скінінг, морфи та spring bones, а також те, що записує VRM Add-on для Blender (стиснення вказане, але не використане, `KHR_texture_transform`, семплери).

## Відомі відмінності та обмеження

- **MToon** наближено неосвітленим матеріалом RealityKit (базовий колір, текстура, режим альфи, двобічність). Контурного світла й межі тіні немає.
- Для **VRM** скінінг і морфи обчислюються на CPU й щокадру записуються в LowLevelMesh. Для моделей із дуже великою кількістю вершин використовуйте збірку Release.
- **Відстеження обличчя** використовує ARKit (TrueDepth), тож недоступне на Mac і Vision Pro. Без точок губ розкриття рота визначається лише з `jawOpen`.
- **visionOS**: VRM у вікні має висоту близько 0,36 м.

## Ліцензія

- Код: Apache License 2.0, як у LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Вбудовані персонажі: ліцензія Apache на них **не** поширюється. Лише некомерційне використання із зазначенням авторства. Kujira і Kujira Q — CC BY-NC-SA 4.0, а на Pen не надано жодних прав. Перед поширенням прочитайте «Ліцензії та торговельні марки» у програмі.
- Назва й логотип LivLiv не охоплені жодною ліцензією.
