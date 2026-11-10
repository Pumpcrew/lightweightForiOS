# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · **Ελληνικά** · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Αυτό το έργο μεταφέρει το [LivLiv Player](https://github.com/livliv-dev/player), ένα πρόγραμμα αναπαραγωγής χαρακτήρων 2.5D για τον ιστό (TypeScript/WebGL2), σε **εγγενή εφαρμογή για iOS, macOS και visionOS**. Οι χαρακτήρες σχεδιάζονται με **Metal** και τα avatar VRM με έναν φορτωτή glTF/VRM γραμμένο για αυτό το έργο πάνω στο **RealityKit**.

## Απαιτήσεις

- iOS 18, macOS 15 ή visionOS 2 ή νεότερο (Xcode 16 ή νεότερο, εργαλεία Swift 6)
- Χωρίς εξωτερικές εξαρτήσεις. Η λογική της εφαρμογής βρίσκεται σε τοπικό πακέτο Swift (`Packages/LivLivKit`).

## Δόμηση

1. Ανοίξτε το `livlivIOSPlayer.xcodeproj` στο Xcode.
2. Στο Signing & Capabilities επιλέξτε το δικό σας Team και, αν χρειάζεται, αλλάξτε το αναγνωριστικό πακέτου.
3. Επιλέξτε ως προορισμό ένα iPhone ή iPad (συσκευή ή προσομοιωτή), το My Mac ή το Apple Vision Pro και πατήστε Run (⌘R).

Το `LivLivCore` δομείται με `-O` ακόμη και σε Debug, επειδή ο σκελετός μετακινεί δεκάδες χιλιάδες κορυφές σε κάθε καρέ (k01: περίπου 17 ms ανά καρέ με `-Onone`, περίπου 2 ms με `-O`).

## Δυνατότητες

- **Χαρακτήρες**: 21 ενσωματωμένοι χαρακτήρες
- **Εισαγωγή**: επιλέξτε έναν φάκελο ή ένα αρχείο που βάλατε στον φάκελο Documents της εφαρμογής. Η εφαρμογή ελέγχει πρώτα ότι μπορεί να το ανοίξει και μετά το φορτώνει. Αν δεν μπορεί, μια ειδοποίηση δείχνει την αιτία σε προβολή κειμένου που μπορείτε να επιλέξετε και να αντιγράψετε.
- Φάκελος Documents: σε iPhone, iPad και Vision Pro, «Αρχεία» › «Στο iPhone μου» › livlivIOSPlayer· σε Mac, «Άνοιγμα φακέλου Documents στο Finder» στην «Εισαγωγή». Η «Επιλογή από άλλη τοποθεσία…» ανοίγει φάκελο ή αρχείο από άλλο σημείο.
- Εκφράσεις, ενέργειες και υπνάκος. Ο χαρακτήρας ακολουθεί τον δείκτη, τα μέρη που αιωρούνται αναπηδούν όταν τα αγγίζετε και μπορείτε να κάνετε ζουμ με τσίμπημα.
- **Συγχρονισμός χειλιών** από το μικρόφωνο ή από αρχείο ήχου και **παρακολούθηση προσώπου** σε iPhone ή iPad με TrueDepth
- **Ρυθμίσεις**: κίνηση, ανάλυση, παρακολούθηση προσώπου και Άδειες ανοιχτού κώδικα › «Άδειες και εμπορικά σήματα»

## Υποστηριζόμενες μορφές

- Φάκελος μοντέλου LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), μαζί με αρχεία που εξήχθησαν με το VRM Add-on για Blender
- Φάκελος PNGTuber: `closed.png`, `open.png` (προαιρετικά: `blink.png`, `blink-open.png`, `name.txt`)

Ένα αρχείο που δεν μπορεί να αναπαραχθεί (VRM χωρίς πλέγμα, συμπίεση Draco / Meshopt / KTX2, πολύ μεγάλες εικόνες) απορρίπτεται με την αιτία.

## Τοπικοποίηση

- Τα κείμενα της εφαρμογής υπάρχουν σε 50 γλώσσες, σε καταλόγους συμβολοσειρών (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Η γλώσσα ανάπτυξης είναι τα αγγλικά, που χρησιμοποιούν και οι τοπικές παραλλαγές των αγγλικών.
- Το έγγραφο «Άδειες και εμπορικά σήματα» εμφανίζεται στα κορεατικά σε συσκευές με κορεατικά και στα αγγλικά αλλού. Τα ονόματα των χαρακτήρων, οι αναφορές δημιουργών και τα πρωτότυπα κείμενα των αδειών δεν μεταφράζονται.
- Αυτό το README υπάρχει στις ίδιες γλώσσες (σύνδεσμοι στην κορυφή). Οι μεταφράσεις δεν έχουν ελεγχθεί ακόμη από φυσικούς ομιλητές, οπότε οι διορθώσεις είναι ευπρόσδεκτες.

## Δομή του έργου

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

## Πρωτότυπο → μεταφορά

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

## Δοκιμές

```sh
cd Packages/LivLivKit
swift test
```

Ελέγχθηκε σε Linux: ανάγνωση των 21 ενσωματωμένων χαρακτήρων και 240 καρέ του καθενός (εκφράσεις, ενέργειες, στόμα, στένσιλ ίριδας), keyforms, αναπήδηση αλυσίδων, ZIP, ανάλυση για συγχρονισμό χειλιών, ανάγνωση και απόρριψη VRM 0.x / 1.0, skinning, morphs και spring bones, καθώς και όσα γράφει το VRM Add-on για Blender (συμπίεση που αναφέρεται αλλά δεν χρησιμοποιείται, `KHR_texture_transform`, samplers).

## Γνωστές διαφορές και όρια

- Το **MToon** προσεγγίζεται με το μη φωτιζόμενο υλικό του RealityKit (βασικό χρώμα, υφή, λειτουργία άλφα, διπλή όψη). Δεν υπάρχει φως περιγράμματος ούτε όριο σκιάς.
- Στα **VRM**, το skinning και τα morphs υπολογίζονται στη CPU και γράφονται σε LowLevelMesh σε κάθε καρέ. Για μοντέλα με πάρα πολλές κορυφές χρησιμοποιήστε δόμηση Release.
- Η **παρακολούθηση προσώπου** χρησιμοποιεί ARKit (TrueDepth), άρα δεν είναι διαθέσιμη σε Mac και Vision Pro. Χωρίς σημεία των χειλιών, το άνοιγμα του στόματος προκύπτει μόνο από το `jawOpen`.
- **visionOS**: ένα VRM έχει ύψος περίπου 0,36 m στο παράθυρο.

## Άδεια

- Κώδικας: Apache License 2.0, όπως το LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Ενσωματωμένοι χαρακτήρες: η άδεια Apache **δεν** ισχύει. Μόνο μη εμπορική χρήση, με αναφορά δημιουργού. Τα Kujira και Kujira Q είναι CC BY-NC-SA 4.0 και για το Pen δεν παραχωρείται κανένα δικαίωμα. Διαβάστε το «Άδειες και εμπορικά σήματα» στην εφαρμογή πριν από τη διανομή.
- Το όνομα και το λογότυπο LivLiv δεν καλύπτονται από καμία άδεια.
