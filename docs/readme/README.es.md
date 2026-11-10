# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · **Español** · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Este proyecto lleva [LivLiv Player](https://github.com/livliv-dev/player), un reproductor de personajes 2.5D para la web (TypeScript/WebGL2), a una **app nativa para iOS, macOS y visionOS**. Los personajes se dibujan con **Metal**, y los avatares VRM con un cargador glTF/VRM escrito para este proyecto sobre **RealityKit**.

## Requisitos

- iOS 18, macOS 15 o visionOS 2 o posterior (Xcode 16 o posterior, cadena de herramientas Swift 6)
- Sin dependencias externas. La lógica de la app está en un paquete Swift local (`Packages/LivLivKit`).

## Compilación

1. Abre `livlivIOSPlayer.xcodeproj` en Xcode.
2. En Signing & Capabilities, elige tu propio Team y cambia el identificador del paquete si lo necesitas.
3. Elige como destino un iPhone o iPad (dispositivo o simulador), My Mac o Apple Vision Pro, y pulsa Run (⌘R).

`LivLivCore` se compila con `-O` incluso en Debug, porque el rig mueve decenas de miles de vértices en cada fotograma (k01: unos 17 ms por fotograma con `-Onone`, unos 2 ms con `-O`).

## Funciones

- **Personajes**: 21 personajes incluidos
- **Importar**: elige una carpeta o un archivo que hayas puesto en la carpeta Documents de la app. La app comprueba primero que puede abrirlo y luego lo carga. Si no puede, una alerta muestra el motivo en una vista de texto que puedes seleccionar y copiar.
- Carpeta Documents: en iPhone, iPad y Vision Pro, Archivos › En mi iPhone › livlivIOSPlayer; en Mac, «Abrir la carpeta Documents en el Finder» en Importar. «Elegir de otra ubicación…» abre una carpeta o un archivo de otro sitio.
- Expresiones, acciones y cabezadas. El personaje sigue el puntero, las partes que se balancean rebotan al tocarlas y puedes pellizcar para ampliar.
- **Sincronización labial** desde el micrófono o un archivo de audio, y **seguimiento facial** en un iPhone o iPad con TrueDepth
- **Ajustes**: movimiento, resolución, seguimiento facial y Licencias de código abierto › «Licencias y marcas»

## Formatos compatibles

- Carpeta de modelo LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), incluidos los archivos exportados con el VRM Add-on para Blender
- Carpeta PNGTuber: `closed.png`, `open.png` (opcional: `blink.png`, `blink-open.png`, `name.txt`)

Un archivo que no se puede reproducir (un VRM sin malla, compresión Draco / Meshopt / KTX2, imágenes demasiado grandes) se rechaza indicando el motivo.

## Localización

- Los textos de la app están en 50 idiomas, en catálogos de cadenas (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). El idioma de desarrollo es el inglés, y las variantes regionales del inglés lo usan.
- El documento «Licencias y marcas» aparece en coreano en los dispositivos en coreano y en inglés en los demás. Los nombres de los personajes, los créditos y los textos originales de las licencias no se traducen.
- Este README está en los mismos idiomas (enlaces arriba). Las traducciones aún no las han revisado hablantes nativos, así que las correcciones son bienvenidas.

## Estructura del proyecto

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

## Original → adaptación

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

## Pruebas

```sh
cd Packages/LivLivKit
swift test
```

Comprobado en Linux: lectura de los 21 personajes incluidos y 240 fotogramas de cada uno (expresiones, acciones, boca, plantilla del iris), keyforms, rebote de cadenas, ZIP, análisis de sincronización labial, lectura y rechazo de VRM 0.x / 1.0, skinning, morphs y spring bones, y lo que escribe el VRM Add-on para Blender (compresión nombrada pero no usada, `KHR_texture_transform`, samplers).

## Diferencias y límites conocidos

- **MToon** se aproxima con el material sin iluminación de RealityKit (color base, textura, modo alfa, doble cara). No hay luz de borde ni límite de sombra.
- En **VRM**, el skinning y los morphs se calculan en la CPU y se escriben en un LowLevelMesh en cada fotograma. Usa una compilación Release para modelos con muchísimos vértices.
- El **seguimiento facial** usa ARKit (TrueDepth), así que no está disponible en Mac ni en Vision Pro. Sin puntos de referencia de los labios, la apertura de la boca sale solo de `jawOpen`.
- **visionOS**: un VRM mide unos 0,36 m de alto en la ventana.

## Licencia

- Código: Apache License 2.0, la misma que LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Personajes incluidos: la licencia Apache **no** se aplica. Solo uso no comercial y con atribución. Kujira y Kujira Q son CC BY-NC-SA 4.0, y Pen no concede ningún derecho. Lee «Licencias y marcas» en la app antes de distribuirla.
- El nombre y el logotipo de LivLiv no están cubiertos por ninguna licencia.
