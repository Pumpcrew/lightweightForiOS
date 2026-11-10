# livlivIOSPlayer

<div dir="rtl">

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · **العربية** · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

ينقل هذا المشروع [LivLiv Player](https://github.com/livliv-dev/player)، وهو مشغّل شخصيات ثنائي ونصف الأبعاد (2.5D) للويب (TypeScript/WebGL2)، إلى **تطبيق أصلي لأنظمة iOS وmacOS وvisionOS**. تُرسم الشخصيات باستخدام **Metal**، وتُرسم صور VRM الرمزية بمحمّل glTF/VRM كُتب لهذا المشروع فوق **RealityKit**.

## المتطلبات

- iOS 18 أو macOS 15 أو visionOS 2 أو أحدث (Xcode 16 أو أحدث، وأدوات Swift 6)
- لا توجد تبعيات خارجية. منطق التطبيق موجود في حزمة Swift محلية (`Packages/LivLivKit`).

## البناء

1. افتح `livlivIOSPlayer.xcodeproj` في Xcode.
2. في Signing & Capabilities، اختر Team الخاص بك، وغيّر معرّف الحزمة إن لزم.
3. اختر جهاز iPhone أو iPad (جهازًا فعليًا أو محاكيًا) أو My Mac أو Apple Vision Pro وجهةً للتشغيل، ثم اضغط Run (⌘R).

يُبنى `LivLivCore` باستخدام `-O` حتى في Debug، لأن الهيكل يحرّك عشرات الآلاف من الرؤوس في كل إطار (في k01: نحو 17 ms لكل إطار مع `-Onone`، ونحو 2 ms مع `-O`).

## الميزات

- **الشخصيات**: ‏21 شخصية مضمّنة
- **استيراد**: اختر مجلدًا أو ملفًا وضعته في مجلد Documents الخاص بالتطبيق. يتحقق التطبيق أولًا من قدرته على فتحه ثم يحمّله. وإن لم يستطع، يعرض تنبيه السبب في عرض نصي يمكنك تحديده ونسخه.
- مجلد Documents: على iPhone وiPad وVision Pro في الملفات › على الـ iPhone › livlivIOSPlayer؛ وعلى Mac عبر «فتح مجلد Documents في Finder» في استيراد. يفتح «اختيار من موقع آخر…» مجلدًا أو ملفًا من مكان آخر.
- تعابير وحركات وغفوة. تتبع الشخصية المؤشر، وترتدّ الأجزاء المتأرجحة عند لمسها، ويمكنك التكبير بالقرص.
- **مزامنة الشفاه** من الميكروفون أو من ملف صوتي، و**تتبّع الوجه** على iPhone أو iPad مزوّد بـ TrueDepth
- **الإعدادات**: الحركة والدقة وتتبّع الوجه، وتراخيص المصادر المفتوحة › «التراخيص والعلامات التجارية»

## التنسيقات المدعومة

- مجلد نموذج LivLiv ‏(`model.json` + `textures/`)، و`.livliv` / `.zip`
- `.vrm` / `.glb` ‏(VRM 0.x / 1.0)، بما في ذلك الملفات المصدّرة بإضافة VRM Add-on لـ Blender
- مجلد PNGTuber: ‏`closed.png` و`open.png` (اختياري: `blink.png` و`blink-open.png` و`name.txt`)

يُرفض الملف الذي لا يمكن تشغيله (VRM بلا شبكة، أو ضغط Draco / Meshopt / KTX2، أو صور كبيرة جدًا) مع ذكر السبب.

## التعريب

- نصوص التطبيق متوفرة بـ 50 لغة في كتالوجات السلاسل (`livlivIOSPlayer/Localizable.xcstrings` و`InfoPlist.xcstrings`). لغة التطوير هي الإنجليزية، وتستخدمها أيضًا المتغيرات الإقليمية للإنجليزية.
- يظهر مستند «التراخيص والعلامات التجارية» بالكورية على الأجهزة الكورية وبالإنجليزية في غيرها. لا تُترجم أسماء الشخصيات ولا الإسنادات ولا النصوص الأصلية للتراخيص.
- هذا الملف README متوفر باللغات نفسها (الروابط في الأعلى). لم يراجع متحدثون أصليون الترجمات بعد، لذا نرحّب بالتصحيحات.

## بنية المشروع

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

## الأصل ← النقل

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

## الاختبارات

```sh
cd Packages/LivLivKit
swift test
```

تم التحقق على Linux: قراءة الشخصيات الـ 21 المضمّنة وتشغيل 240 إطارًا من كل منها (التعابير، الحركات، الفم، استنسل القزحية)، وkeyforms، وارتداد السلاسل، وZIP، وتحليل مزامنة الشفاه، وقراءة VRM 0.x / 1.0 ورفضه، والجلد (skinning) والتحويلات (morphs) وspring bones، وما تكتبه إضافة VRM Add-on لـ Blender (ضغط مذكور غير مستخدم، و`KHR_texture_transform`، وعيّنات الأخذ).

## الفروق والقيود المعروفة

- يُقرَّب **MToon** بمادة RealityKit غير المضاءة (اللون الأساسي، النسيج، وضع ألفا، الوجهان). لا يوجد ضوء حافة ولا حدّ للظل.
- في **VRM** يُحسب الجلد والتحويلات على وحدة المعالجة المركزية وتُكتب في LowLevelMesh في كل إطار. استخدم بناء Release للنماذج ذات الرؤوس الكثيرة جدًا.
- يستخدم **تتبّع الوجه** ‏ARKit (TrueDepth)، لذا فهو غير متاح على Mac وVision Pro. ولعدم وجود معالم للشفاه، يُحدَّد فتح الفم من `jawOpen` وحده.
- **visionOS**: يبلغ ارتفاع VRM في النافذة نحو 0.36 m.

## الترخيص

- الشيفرة: Apache License 2.0، مثل LivLiv Player ‏(`livlivIOSPlayer/Resources/Legal/`).
- الشخصيات المضمّنة: ترخيص Apache **لا** ينطبق عليها. للاستخدام غير التجاري فقط مع ذكر المصدر. Kujira وKujira Q مرخّصتان بـ CC BY-NC-SA 4.0، ولا يُمنح أي حق في Pen. اقرأ «التراخيص والعلامات التجارية» في التطبيق قبل توزيعه.
- اسم LivLiv وشعاره غير مشمولين بأي ترخيص.

</div>
