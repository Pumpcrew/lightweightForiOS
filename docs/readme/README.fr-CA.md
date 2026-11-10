# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · **Français (Canada)** · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Ce projet porte [LivLiv Player](https://github.com/livliv-dev/player), un lecteur de personnages 2.5D pour le web (TypeScript/WebGL2), vers une **app native pour iOS, macOS et visionOS**. Les personnages sont dessinés avec **Metal**, et les avatars VRM avec un chargeur glTF/VRM écrit pour ce projet sur **RealityKit**.

## Configuration requise

- iOS 18, macOS 15 ou visionOS 2 ou version ultérieure (Xcode 16 ou version ultérieure, chaîne d’outils Swift 6)
- Aucune dépendance externe. La logique de l’app se trouve dans un paquet Swift local (`Packages/LivLivKit`).

## Compilation

1. Ouvrez `livlivIOSPlayer.xcodeproj` dans Xcode.
2. Dans Signing & Capabilities, choisissez votre propre Team et modifiez l’identifiant de paquet si besoin.
3. Choisissez un iPhone ou un iPad (appareil ou simulateur), My Mac ou Apple Vision Pro comme destination, puis touchez Run (⌘R).

`LivLivCore` est compilé avec `-O` même en Debug, car le rig déplace des dizaines de milliers de sommets à chaque image (k01 : environ 17 ms par image en `-Onone`, environ 2 ms en `-O`).

## Fonctionnalités

- **Personnages** : 21 personnages fournis
- **Importer** : choisissez un dossier ou un fichier placé dans le dossier Documents de l’app. L’app vérifie d’abord qu’elle peut l’ouvrir, puis le charge. Sinon, une alerte en donne la raison dans une vue de texte que l’on peut sélectionner et copier.
- Dossier Documents : sur iPhone, iPad et Vision Pro, Fichiers › Sur mon iPhone › livlivIOSPlayer ; sur Mac, « Ouvrir le dossier Documents dans le Finder » dans Importer. « Choisir dans un autre emplacement… » ouvre un dossier ou un fichier situé ailleurs.
- Expressions, actions et somnolence. Le personnage suit le pointeur, les parties qui se balancent rebondissent au toucher, et l’on peut pincer pour zoomer.
- **Synchronisation labiale** depuis le microphone ou un fichier audio, et **suivi du visage** sur un iPhone ou un iPad avec TrueDepth
- **Réglages** : mouvement, résolution, suivi du visage, et Licences libres › « Licences et marques »

## Formats pris en charge

- Dossier de modèle LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), y compris les fichiers exportés par le VRM Add-on pour Blender
- Dossier PNGTuber : `closed.png`, `open.png` (facultatif : `blink.png`, `blink-open.png`, `name.txt`)

Un fichier qui ne peut pas être lu (un VRM sans maillage, une compression Draco / Meshopt / KTX2, des images trop grandes) est refusé avec la raison.

## Localisation

- Les textes de l’app existent en 50 langues, dans des catalogues de chaînes (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). La langue de développement est l’anglais, que les variantes régionales de l’anglais utilisent.
- Le document « Licences et marques » est en coréen sur les appareils en coréen et en anglais ailleurs. Les noms des personnages, les crédits et les textes originaux des licences ne sont pas traduits.
- Ce README existe dans les mêmes langues (liens en haut). Les traductions n’ont pas encore été relues par des locuteurs natifs : les corrections sont les bienvenues.

## Structure du projet

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

## Original → portage

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

## Tests

```sh
cd Packages/LivLivKit
swift test
```

Vérifié sous Linux : lecture des 21 personnages fournis et 240 images de chacun (expressions, actions, bouche, stencil de l’iris), keyforms, rebond des chaînes, ZIP, analyse de la synchronisation labiale, lecture et refus de VRM 0.x / 1.0, skinning, morphs et spring bones, et ce qu’écrit le VRM Add-on pour Blender (compression nommée mais non utilisée, `KHR_texture_transform`, samplers).

## Différences et limites connues

- **MToon** est approché par le matériau non éclairé de RealityKit (couleur de base, texture, mode alpha, double face). Il n’y a ni lumière de contour ni limite d’ombre.
- Pour les **VRM**, le skinning et les morphs sont calculés sur le CPU et écrits dans un LowLevelMesh à chaque image. Utilisez une compilation Release pour les modèles qui ont énormément de sommets.
- Le **suivi du visage** utilise ARKit (TrueDepth) : il n’est donc pas disponible sur Mac ni sur Vision Pro. Faute de repères des lèvres, l’ouverture de la bouche vient seulement de `jawOpen`.
- **visionOS** : un VRM mesure environ 0,36 m de haut dans la fenêtre.

## Licence

- Code : Apache License 2.0, comme LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Personnages fournis : la licence Apache ne s’applique **pas**. Usage non commercial uniquement, avec attribution. Kujira et Kujira Q sont sous CC BY-NC-SA 4.0, et Pen ne donne aucun droit. Lisez « Licences et marques » dans l’app avant de la distribuer.
- Le nom et le logo LivLiv ne sont couverts par aucune licence.
