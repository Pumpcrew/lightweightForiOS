# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · **Català** · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Aquest projecte porta [LivLiv Player](https://github.com/livliv-dev/player), un reproductor de personatges 2.5D per al web (TypeScript/WebGL2), a una **app nativa per a iOS, macOS i visionOS**. Els personatges es dibuixen amb **Metal**, i els avatars VRM amb un carregador glTF/VRM escrit per a aquest projecte sobre **RealityKit**.

## Requisits

- iOS 18, macOS 15 o visionOS 2 o posterior (Xcode 16 o posterior, eines de Swift 6)
- Sense dependències externes. La lògica de l’app és en un paquet Swift local (`Packages/LivLivKit`).

## Compilació

1. Obre `livlivIOSPlayer.xcodeproj` a l’Xcode.
2. A Signing & Capabilities, tria el teu Team i, si cal, canvia l’identificador del paquet.
3. Tria com a destinació un iPhone o iPad (dispositiu o simulador), My Mac o Apple Vision Pro i prem Run (⌘R).

`LivLivCore` es compila amb `-O` fins i tot en Debug, perquè el rig mou desenes de milers de vèrtexs a cada fotograma (k01: uns 17 ms per fotograma amb `-Onone`, uns 2 ms amb `-O`).

## Funcions

- **Personatges**: 21 personatges inclosos
- **Importa**: tria una carpeta o un fitxer que hagis posat a la carpeta Documents de l’app. L’app primer comprova que el pot obrir i després el carrega. Si no pot, un avís mostra el motiu en una vista de text que pots seleccionar i copiar.
- Carpeta Documents: a l’iPhone, l’iPad i el Vision Pro, Fitxers › Al meu iPhone › livlivIOSPlayer; al Mac, «Obre la carpeta Documents al Finder» a Importa. «Tria d’una altra ubicació…» obre una carpeta o un fitxer d’un altre lloc.
- Expressions, accions i becaines. El personatge segueix el punter, les parts que es gronxen reboten quan les toques i pots pessigar per ampliar.
- **Sincronització labial** des del micròfon o un fitxer d’àudio, i **seguiment facial** en un iPhone o iPad amb TrueDepth
- **Configuració**: moviment, resolució, seguiment facial i Llicències de codi obert › «Llicències i marques comercials»

## Formats compatibles

- Carpeta de model LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), inclosos els fitxers exportats amb el VRM Add-on per a Blender
- Carpeta PNGTuber: `closed.png`, `open.png` (opcional: `blink.png`, `blink-open.png`, `name.txt`)

Un fitxer que no es pot reproduir (un VRM sense malla, compressió Draco / Meshopt / KTX2, imatges massa grans) es rebutja indicant-ne el motiu.

## Localització

- Els textos de l’app són en 50 idiomes, en catàlegs de cadenes (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). L’idioma de desenvolupament és l’anglès, que fan servir també les variants regionals de l’anglès.
- El document «Llicències i marques comercials» surt en coreà als dispositius en coreà i en anglès a la resta. Els noms dels personatges, els crèdits i els textos originals de les llicències no es tradueixen.
- Aquest README és en els mateixos idiomes (enllaços a dalt). Les traduccions encara no les han revisat parlants nadius, així que les correccions són benvingudes.

## Estructura del projecte

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

## Original → adaptació

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

## Proves

```sh
cd Packages/LivLivKit
swift test
```

Comprovat a Linux: lectura dels 21 personatges inclosos i 240 fotogrames de cadascun (expressions, accions, boca, plantilla de l’iris), keyforms, rebot de cadenes, ZIP, anàlisi de sincronització labial, lectura i rebuig de VRM 0.x / 1.0, skinning, morphs i spring bones, i el que escriu el VRM Add-on per a Blender (compressió esmentada però no utilitzada, `KHR_texture_transform`, samplers).

## Diferències i límits coneguts

- **MToon** s’aproxima amb el material sense il·luminació de RealityKit (color base, textura, mode alfa, doble cara). No hi ha llum de contorn ni límit d’ombra.
- Als **VRM**, el skinning i els morphs es calculen a la CPU i s’escriuen en un LowLevelMesh a cada fotograma. Per a models amb moltíssims vèrtexs, fes servir una compilació Release.
- El **seguiment facial** fa servir ARKit (TrueDepth), de manera que no està disponible al Mac ni al Vision Pro. Sense punts de referència dels llavis, l’obertura de la boca surt només de `jawOpen`.
- **visionOS**: un VRM fa uns 0,36 m d’alçada a la finestra.

## Llicència

- Codi: Apache License 2.0, la mateixa que LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Personatges inclosos: la llicència Apache **no** s’hi aplica. Només ús no comercial i amb atribució. Kujira i Kujira Q són CC BY-NC-SA 4.0, i Pen no concedeix cap dret. Llegeix «Llicències i marques comercials» a l’app abans de distribuir-la.
- El nom i el logotip de LivLiv no estan coberts per cap llicència.
