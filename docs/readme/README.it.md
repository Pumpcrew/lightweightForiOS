# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · **Italiano** · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Questo progetto porta [LivLiv Player](https://github.com/livliv-dev/player), un player di personaggi 2.5D per il web (TypeScript/WebGL2), in un’**app nativa per iOS, macOS e visionOS**. I personaggi sono disegnati con **Metal**, e gli avatar VRM con un caricatore glTF/VRM scritto per questo progetto su **RealityKit**.

## Requisiti

- iOS 18, macOS 15 o visionOS 2 o versioni successive (Xcode 16 o successivo, toolchain Swift 6)
- Nessuna dipendenza esterna. La logica dell’app si trova in un pacchetto Swift locale (`Packages/LivLivKit`).

## Compilazione

1. Apri `livlivIOSPlayer.xcodeproj` in Xcode.
2. In Signing & Capabilities scegli il tuo Team e, se serve, cambia l’identificatore del bundle.
3. Scegli come destinazione un iPhone o un iPad (dispositivo o simulatore), My Mac o Apple Vision Pro, poi premi Run (⌘R).

`LivLivCore` viene compilato con `-O` anche in Debug, perché il rig muove decine di migliaia di vertici a ogni fotogramma (k01: circa 17 ms per fotogramma con `-Onone`, circa 2 ms con `-O`).

## Funzionalità

- **Personaggi**: 21 personaggi inclusi
- **Importa**: scegli una cartella o un file che hai messo nella cartella Documents dell’app. L’app controlla prima di poterlo aprire, poi lo carica. Se non può, un avviso mostra il motivo in una vista di testo che puoi selezionare e copiare.
- Cartella Documents: su iPhone, iPad e Vision Pro, File › Sul mio iPhone › livlivIOSPlayer; su Mac, «Apri la cartella Documents nel Finder» in Importa. «Scegli da un’altra posizione…» apre una cartella o un file altrove.
- Espressioni, azioni e pisolini. Il personaggio segue il puntatore, le parti che oscillano rimbalzano quando le tocchi e puoi pizzicare per ingrandire.
- **Sincronizzazione labiale** dal microfono o da un file audio e **tracciamento del viso** su un iPhone o un iPad con TrueDepth
- **Impostazioni**: movimento, risoluzione, tracciamento del viso e Licenze open source › «Licenze e marchi»

## Formati supportati

- Cartella del modello LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), compresi i file esportati con il VRM Add-on per Blender
- Cartella PNGTuber: `closed.png`, `open.png` (facoltativi: `blink.png`, `blink-open.png`, `name.txt`)

Un file che non si può riprodurre (un VRM senza mesh, compressione Draco / Meshopt / KTX2, immagini troppo grandi) viene rifiutato indicandone il motivo.

## Localizzazione

- I testi dell’app sono in 50 lingue, in cataloghi di stringhe (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). La lingua di sviluppo è l’inglese, che usano anche le varianti regionali dell’inglese.
- Il documento «Licenze e marchi» è in coreano sui dispositivi in coreano e in inglese altrove. I nomi dei personaggi, i crediti e i testi originali delle licenze non sono tradotti.
- Questo README è disponibile nelle stesse lingue (link in alto). Le traduzioni non sono ancora state riviste da madrelingua, quindi le correzioni sono benvenute.

## Struttura del progetto

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

## Originale → porting

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

## Test

```sh
cd Packages/LivLivKit
swift test
```

Verificato su Linux: lettura dei 21 personaggi inclusi e 240 fotogrammi di ciascuno (espressioni, azioni, bocca, stencil dell’iride), keyform, rimbalzo delle catene, ZIP, analisi della sincronizzazione labiale, lettura e rifiuto di VRM 0.x / 1.0, skinning, morph e spring bone, e ciò che scrive il VRM Add-on per Blender (compressione dichiarata ma non usata, `KHR_texture_transform`, sampler).

## Differenze e limiti noti

- **MToon** è approssimato con il materiale non illuminato di RealityKit (colore base, texture, modalità alfa, doppia faccia). Mancano luce di contorno e confine d’ombra.
- Per i **VRM**, skinning e morph sono calcolati sulla CPU e scritti in una LowLevelMesh a ogni fotogramma. Per modelli con moltissimi vertici usa una build Release.
- Il **tracciamento del viso** usa ARKit (TrueDepth), quindi non è disponibile su Mac né su Vision Pro. Senza punti di riferimento delle labbra, l’apertura della bocca deriva solo da `jawOpen`.
- **visionOS**: un VRM è alto circa 0,36 m nella finestra.

## Licenza

- Codice: Apache License 2.0, come LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Personaggi inclusi: la licenza Apache **non** si applica. Solo uso non commerciale, con attribuzione. Kujira e Kujira Q sono CC BY-NC-SA 4.0, e Pen non concede alcun diritto. Leggi «Licenze e marchi» nell’app prima di distribuirla.
- Il nome e il logo LivLiv non sono coperti da alcuna licenza.
