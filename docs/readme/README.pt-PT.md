# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · **Português (Portugal)** · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Este projeto leva o [LivLiv Player](https://github.com/livliv-dev/player), um player de personagens 2.5D para a web (TypeScript/WebGL2), para um **app nativa para iOS, macOS e visionOS**. Os personagens são desenhados com **Metal**, e os avatares VRM com um carregador glTF/VRM escrito para este projeto sobre o **RealityKit**.

## Requisitos

- iOS 18, macOS 15 ou visionOS 2 ou posterior (Xcode 16 ou posterior, toolchain Swift 6)
- Sem dependências externas. A lógica da app fica num pacote Swift local (`Packages/LivLivKit`).

## Compilação

1. Abra `livlivIOSPlayer.xcodeproj` no Xcode.
2. Em Signing & Capabilities, escolha o seu próprio Team e, se precisar, altere o identificador do pacote.
3. Escolha um iPhone ou iPad (dispositivo ou simulador), My Mac ou Apple Vision Pro como destino e prima Run (⌘R).

O `LivLivCore` é compilado com `-O` mesmo em Debug, porque o rig move dezenas de milhares de vértices a cada quadro (k01: cerca de 17 ms por quadro com `-Onone`, cerca de 2 ms com `-O`).

## Funcionalidades

- **Personagens**: 21 personagens incluídos
- **Importar**: escolha uma pasta ou um ficheiro que colocou na pasta Documents da app. A app primeiro verifica se consegue abri-lo e depois o carrega. Se não conseguir, um alerta mostra o motivo numa visualização de texto que pode ser selecionada e copiada.
- Pasta Documents: no iPhone, iPad e Vision Pro, Ficheiros › No meu iPhone › livlivIOSPlayer; no Mac, “Abrir a pasta Documents no Finder” em Importar. “Escolher de outro local…” abre uma pasta ou um ficheiro em outro lugar.
- Expressões, ações e cochilos. O personagem segue o ponteiro, as partes que balançam saltam ao toque e pode beliscar para ampliar.
- **Sincronização labial** pelo microfone ou por um ficheiro de áudio, e **rastreamento facial** em iPhone ou iPad com TrueDepth
- **Definições**: movimento, resolução, rastreamento facial e Licenças de código aberto › “Licenças e marcas”

## Formatos compatíveis

- Pasta de modelo LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), incluindo ficheiros exportados pelo VRM Add-on para Blender
- Pasta PNGTuber: `closed.png`, `open.png` (opcionais: `blink.png`, `blink-open.png`, `name.txt`)

Um ficheiro que não pode ser reproduzido (um VRM sem malha, compressão Draco / Meshopt / KTX2, imagens grandes demais) é recusado com o motivo.

## Localização

- Os textos da app estão em 50 idiomas, em catálogos de strings (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). O idioma de desenvolvimento é o inglês, usado também pelas variantes regionais do inglês.
- O documento “Licenças e marcas” aparece em coreano em dispositivos em coreano e em inglês nos demais. Nomes dos personagens, créditos e textos originais das licenças não são traduzidos.
- Este README está nos mesmos idiomas (links no topo). As traduções ainda não foram revisadas por falantes nativos, então correções são bem-vindas.

## Estrutura do projeto

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

## Original → port

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

## Testes

```sh
cd Packages/LivLivKit
swift test
```

Verificado em Linux: leitura dos 21 personagens incluídos e 240 quadros de cada um (expressões, ações, boca, estêncil da íris), keyforms, salto das correntes, ZIP, análise de sincronização labial, leitura e recusa de VRM 0.x / 1.0, skinning, morphs e spring bones, e o que o VRM Add-on para Blender escreve (compressão citada mas não usada, `KHR_texture_transform`, samplers).

## Diferenças e limites conhecidos

- O **MToon** é aproximado com o material sem iluminação do RealityKit (cor base, textura, modo alfa, dupla face). Não há luz de borda nem limite de sombra.
- Nos **VRM**, skinning e morphs são calculados na CPU e escrevedos num LowLevelMesh a cada quadro. Utilize uma compilação Release para modelos com muitíssimos vértices.
- O **rastreamento facial** usa o ARKit (TrueDepth), por isso não está disponível no Mac nem no Vision Pro. Sem pontos de referência dos lábios, a abertura da boca vem só de `jawOpen`.
- **visionOS**: um VRM fica com cerca de 0,36 m de altura na janela.

## Licença

- Código: Apache License 2.0, a mesma do LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Personagens incluídos: a licença Apache **não** se aplica. Somente uso não comercial, com atribuição. Kujira e Kujira Q são CC BY-NC-SA 4.0, e Pen não concede nenhum direito. Leia “Licenças e marcas” na app antes de distribuí-la.
- O nome e o logotipo LivLiv não estão cobertos por nenhuma licença.
