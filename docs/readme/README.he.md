# livlivIOSPlayer

<div dir="rtl">

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · **עברית** · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

פרויקט זה מעביר את [LivLiv Player](https://github.com/livliv-dev/player), נגן דמויות 2.5D לרשת (TypeScript/WebGL2), ל**יישום מקורי ל‑iOS, ‏macOS ו‑visionOS**. הדמויות מצוירות באמצעות **Metal**, ואווטארים של VRM באמצעות טוען glTF/VRM שנכתב לפרויקט זה על גבי **RealityKit**.

## דרישות

- iOS 18, ‏macOS 15 או visionOS 2 ואילך (Xcode 16 ואילך, כלי Swift 6)
- אין תלויות חיצוניות. הלוגיקה של היישום נמצאת בחבילת Swift מקומית (`Packages/LivLivKit`).

## בנייה

1. פתח/י את `livlivIOSPlayer.xcodeproj` ב‑Xcode.
2. ב‑Signing & Capabilities בחר/י את ה‑Team שלך, ושנה/י את מזהה החבילה אם צריך.
3. בחר/י יעד הרצה – iPhone או iPad (מכשיר או סימולטור), ‏My Mac או Apple Vision Pro – ולחץ/י על Run ‏(⌘R).

‏`LivLivCore` נבנה עם `-O` גם ב‑Debug, כי השלד מזיז עשרות אלפי קודקודים בכל פריים (k01: כ‑17 ms לפריים עם `-Onone`, כ‑2 ms עם `-O`).

## תכונות

- **דמויות**: ‏21 דמויות מצורפות
- **ייבוא**: בחר/י תיקייה או קובץ ששמת בתיקייה Documents של היישום. היישום בודק קודם שהוא יכול לפתוח אותם ואז טוען. אם לא, התראה מציגה את הסיבה בתצוגת טקסט שאפשר לבחור ולהעתיק.
- התיקייה Documents: ב‑iPhone, ‏iPad ו‑Vision Pro – ״קבצים״ › ״ב‑iPhone שלי״ › livlivIOSPlayer; ב‑Mac – ״פתח את Documents ב‑Finder״ תחת ״ייבוא״. ״בחר ממיקום אחר…״ פותח תיקייה או קובץ ממקום אחר.
- הבעות, פעולות ונמנום. הדמות עוקבת אחרי המצביע, חלקים מתנדנדים קופצים בהקשה, ואפשר לצבוט כדי להגדיל.
- **סנכרון שפתיים** מהמיקרופון או מקובץ שמע, ו**מעקב פנים** ב‑iPhone או iPad עם TrueDepth
- **הגדרות**: תנועה, רזולוציה, מעקב פנים ו‑רישיונות קוד פתוח › ״רישיונות וסימנים מסחריים״

## פורמטים נתמכים

- תיקיית מודל LivLiv ‏(`model.json` + `textures/`), ‏`.livliv` / `.zip`
- ‏`.vrm` / `.glb` ‏(VRM 0.x / 1.0), כולל קבצים שיוצאו באמצעות VRM Add-on ל‑Blender
- תיקיית PNGTuber: ‏`closed.png`, ‏`open.png` (אופציונלי: `blink.png`, ‏`blink-open.png`, ‏`name.txt`)

קובץ שאי אפשר לנגן (VRM בלי רשת, דחיסת Draco / Meshopt / KTX2, תמונות גדולות מדי) נדחה עם הסיבה.

## לוקליזציה

- הטקסטים של היישום קיימים ב‑50 שפות, בקטלוגי מחרוזות (`livlivIOSPlayer/Localizable.xcstrings`, ‏`InfoPlist.xcstrings`). שפת הפיתוח היא אנגלית, וגם הגרסאות האזוריות של אנגלית משתמשות בה.
- המסמך ״רישיונות וסימנים מסחריים״ מוצג בקוריאנית במכשירים בקוריאנית ובאנגלית בכל השאר. שמות הדמויות, הקרדיטים והנוסח המקורי של הרישיונות אינם מתורגמים.
- קובץ README זה זמין באותן שפות (קישורים למעלה). התרגומים עדיין לא נבדקו על ידי דוברים ילידיים, ולכן תיקונים יתקבלו בברכה.

## מבנה הפרויקט

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

## מקור ← הסבה

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

## בדיקות

```sh
cd Packages/LivLivKit
swift test
```

נבדק ב‑Linux: קריאת 21 הדמויות המצורפות ו‑240 פריימים מכל אחת (הבעות, פעולות, פה, סטנסיל קשתית), ‏keyforms, קפיצת שרשראות, ‏ZIP, ניתוח לסנכרון שפתיים, קריאה ודחייה של VRM 0.x / 1.0, ‏skinning, ‏morphs ו‑spring bones, וגם מה ש‑VRM Add-on ל‑Blender כותב (דחיסה שמוזכרת אך אינה בשימוש, ‏`KHR_texture_transform`, ‏samplers).

## הבדלים ומגבלות ידועים

- ‏**MToon** מקורב באמצעות החומר הלא‑מואר של RealityKit (צבע בסיס, טקסטורה, מצב אלפא, דו‑צדדיות). אין אור שוליים וגבול צל.
- ב‑**VRM**, ה‑skinning וה‑morphs מחושבים במעבד ונכתבים ל‑LowLevelMesh בכל פריים. למודלים עם הרבה מאוד קודקודים מומלצת בניית Release.
- **מעקב פנים** משתמש ב‑ARKit ‏(TrueDepth), ולכן אינו זמין ב‑Mac וב‑Vision Pro. בהיעדר נקודות שפתיים, פתיחת הפה נקבעת רק מ‑`jawOpen`.
- ‏**visionOS**: גובהו של VRM בחלון הוא כ‑0.36 m.

## רישיון

- קוד: Apache License 2.0, כמו ב‑LivLiv Player ‏(`livlivIOSPlayer/Resources/Legal/`).
- דמויות מצורפות: רישיון Apache **אינו** חל עליהן. לשימוש לא מסחרי בלבד, עם ייחוס. ‏Kujira ו‑Kujira Q הן CC BY-NC-SA 4.0, ול‑Pen לא ניתנות זכויות כלל. קרא/י את ״רישיונות וסימנים מסחריים״ ביישום לפני הפצה.
- השם והלוגו LivLiv אינם מכוסים בשום רישיון.

</div>
