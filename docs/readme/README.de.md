# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · **Deutsch** · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Dieses Projekt portiert [LivLiv Player](https://github.com/livliv-dev/player), einen 2.5D-Figurenplayer für das Web (TypeScript/WebGL2), in eine **native App für iOS, macOS und visionOS**. Figuren werden mit **Metal** gezeichnet, VRM-Avatare mit einem für dieses Projekt geschriebenen glTF/VRM-Lader auf **RealityKit**.

## Voraussetzungen

- iOS 18, macOS 15 oder visionOS 2 oder neuer (Xcode 16 oder neuer, Swift-6-Toolchain)
- Keine externen Abhängigkeiten. Die Logik der App liegt in einem lokalen Swift-Paket (`Packages/LivLivKit`).

## Erstellen

1. Öffne `livlivIOSPlayer.xcodeproj` in Xcode.
2. Wähle unter Signing & Capabilities dein eigenes Team und ändere bei Bedarf die Bundle-ID.
3. Wähle ein iPhone oder iPad (Gerät oder Simulator), My Mac oder Apple Vision Pro als Ziel und drücke Run (⌘R).

`LivLivCore` wird auch in Debug mit `-O` erstellt, weil das Rig pro Bild Zehntausende Vertices bewegt (k01: etwa 17 ms pro Bild mit `-Onone`, etwa 2 ms mit `-O`).

## Funktionen

- **Figuren**: 21 mitgelieferte Figuren
- **Importieren**: Wähle einen Ordner oder eine Datei, die du in den Documents-Ordner der App gelegt hast. Die App prüft zuerst, ob sie sie öffnen kann, und lädt sie dann. Wenn nicht, zeigt eine Warnung den Grund in einer Textansicht, die du auswählen und kopieren kannst.
- Documents-Ordner: auf iPhone, iPad und Vision Pro unter Dateien › Auf meinem iPhone › livlivIOSPlayer, auf dem Mac über „Ordner „Documents“ im Finder öffnen“ in Importieren. „Von einem anderen Ort wählen …“ öffnet einen Ordner oder eine Datei an einem anderen Ort.
- Gesichtsausdrücke, Aktionen und Dösen. Die Figur folgt dem Zeiger, schwingende Teile federn beim Tippen, und du kannst mit zwei Fingern zoomen.
- **Lippensynchronisierung** über das Mikrofon oder eine Audiodatei und **Gesichtserkennung** auf einem iPhone oder iPad mit TrueDepth
- **Einstellungen**: Bewegung, Auflösung, Gesichtserkennung und Open-Source-Lizenzen › „Lizenzen und Marken“

## Unterstützte Formate

- LivLiv-Modellordner (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), auch Dateien, die mit dem VRM Add-on für Blender exportiert wurden
- PNGTuber-Ordner: `closed.png`, `open.png` (optional: `blink.png`, `blink-open.png`, `name.txt`)

Eine Datei, die nicht abgespielt werden kann (ein VRM ohne Mesh, Draco-/Meshopt-/KTX2-Komprimierung, zu große Bilder), wird mit dem Grund abgelehnt.

## Lokalisierung

- Die Texte der App gibt es in 50 Sprachen, in String-Katalogen (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Die Entwicklungssprache ist Englisch; regionale Varianten des Englischen verwenden es.
- Das Dokument „Lizenzen und Marken“ erscheint auf koreanischen Geräten auf Koreanisch und sonst auf Englisch. Figurennamen, Nennungen und die Originaltexte der Lizenzen werden nicht übersetzt.
- Diese README gibt es in denselben Sprachen (Links oben). Die Übersetzungen wurden noch nicht von Muttersprachlern geprüft; Korrekturen sind willkommen.

## Projektaufbau

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

## Original → Portierung

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

Unter Linux geprüft: Lesen der 21 mitgelieferten Figuren und je 240 Bilder davon (Ausdrücke, Aktionen, Mund, Iris-Stencil), Keyforms, Federn der Ketten, ZIP, Analyse der Lippensynchronisierung, Lesen und Ablehnen von VRM 0.x / 1.0, Skinning, Morphs und Spring Bones sowie das, was das VRM Add-on für Blender schreibt (genannte, aber nicht genutzte Komprimierung, `KHR_texture_transform`, Sampler).

## Bekannte Unterschiede und Grenzen

- **MToon** wird mit dem unbeleuchteten Material von RealityKit angenähert (Grundfarbe, Textur, Alphamodus, Beidseitigkeit). Randlicht und Schattengrenze gibt es nicht.
- Bei **VRM** werden Skinning und Morphs auf der CPU berechnet und jedes Bild in ein LowLevelMesh geschrieben. Für Modelle mit sehr vielen Vertices empfiehlt sich ein Release-Build.
- Die **Gesichtserkennung** nutzt ARKit (TrueDepth) und ist daher auf Mac und Vision Pro nicht verfügbar. Ohne Lippenmarker ergibt sich die Mundöffnung allein aus `jawOpen`.
- **visionOS**: Ein VRM ist im Fenster etwa 0,36 m groß.

## Lizenz

- Code: Apache License 2.0, wie bei LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Mitgelieferte Figuren: Die Apache-Lizenz gilt **nicht**. Nur nicht kommerzielle Nutzung, mit Namensnennung. Kujira und Kujira Q stehen unter CC BY-NC-SA 4.0, für Pen werden keinerlei Rechte eingeräumt. Lies vor dem Verteilen „Lizenzen und Marken“ in der App.
- Name und Logo von LivLiv sind von keiner Lizenz erfasst.
