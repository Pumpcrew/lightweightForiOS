# livlivIOSPlayer

[English](../../README.md) · **한국어** · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

웹용 2.5D 캐릭터 플레이어 [LivLiv Player](https://github.com/livliv-dev/player)(TypeScript/WebGL2)를 **iOS · macOS · visionOS 네이티브 앱**으로 옮긴 프로젝트입니다. 캐릭터는 **Metal**로 그리고, VRM 아바타는 이 프로젝트를 위해 **RealityKit** 위에 직접 만든 glTF/VRM 로더로 그립니다.

## 요구 사항

- iOS 18, macOS 15, visionOS 2 이상 (Xcode 16 이상, Swift 6 툴체인)
- 외부 의존성이 없습니다. 앱 로직은 로컬 Swift 패키지(`Packages/LivLivKit`)에 있습니다.

## 빌드

1. Xcode에서 `livlivIOSPlayer.xcodeproj`를 엽니다.
2. Signing & Capabilities에서 본인의 Team을 고르고, 필요하면 번들 ID를 바꿉니다.
3. 실행 대상으로 iPhone이나 iPad(기기 또는 시뮬레이터), My Mac, Apple Vision Pro 중 하나를 고른 뒤 Run(⌘R)을 누릅니다.

`LivLivCore`는 Debug에서도 `-O`로 빌드합니다. 리그가 한 프레임에 수만 개의 정점을 움직이기 때문입니다(k01 기준 `-Onone`에서 프레임당 약 17 ms, `-O`에서 약 2 ms).

## 기능

- **캐릭터**: 동봉 캐릭터 21종
- **가져오기**: 앱의 Documents 폴더에 넣은 폴더나 파일을 고르면, 먼저 열 수 있는지 검사한 뒤 불러옵니다. 열 수 없으면 사유를 선택·복사할 수 있는 텍스트 뷰로 된 Alert에 보여 줍니다.
- Documents 폴더 위치: iPhone, iPad, Vision Pro에서는 파일 앱 › 나의 iPhone › livlivIOSPlayer, Mac에서는 가져오기의 「Finder에서 Documents 폴더 열기」. 「다른 위치에서 선택…」로 다른 곳의 폴더나 파일도 열 수 있습니다.
- 표정, 액션, 졸기. 캐릭터가 포인터를 따라보고, 탭하면 흔들리는 부분이 튕기며, 핀치로 확대할 수 있습니다.
- 마이크나 음성 파일로 하는 **립싱크**, TrueDepth가 있는 iPhone·iPad에서 하는 **얼굴 추적**
- **설정**: 움직임, 해상도, 얼굴 추적, 오픈 소스 라이선스 › 「라이선스와 상표」

## 지원 형식

- LivLiv 모델 폴더(`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0). Blender용 VRM Add-on으로 내보낸 파일도 포함
- PNGTuber 폴더: `closed.png`, `open.png` (선택: `blink.png`, `blink-open.png`, `name.txt`)

재생할 수 없는 파일(메시가 없는 VRM, Draco / Meshopt / KTX2 압축, 너무 큰 그림)은 사유와 함께 거절합니다.

## 다국어

- 앱의 텍스트는 50개 언어로 String Catalog(`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`)에 들어 있습니다. 개발 언어는 영어이고, 지역별 영어 변형도 영어를 씁니다.
- 「라이선스와 상표」 문서는 한국어 기기에서는 한국어로, 그 밖에서는 영어로 나옵니다. 캐릭터 이름, 출처 표기, 원문 라이선스는 번역하지 않습니다.
- 이 README도 같은 언어로 제공합니다(맨 위 링크). 번역은 아직 원어민 검토를 거치지 않았으니 수정 제안을 환영합니다.

## 구조

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

## 원본 → 포팅

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

## 테스트

```sh
cd Packages/LivLivKit
swift test
```

Linux에서 확인한 것: 동봉 캐릭터 21종 읽기와 각 240프레임 재생(표정, 액션, 입 모양, 홍채 스텐실), 키폼, 체인 튕기기, ZIP, 립싱크 분석, VRM 0.x / 1.0 읽기와 거절, 스키닝·모프·스프링본, Blender용 VRM Add-on이 쓰는 내용(이름만 있고 쓰지 않는 압축, `KHR_texture_transform`, 샘플러).

## 알려진 차이와 한계

- **MToon**은 RealityKit의 Unlit 머티리얼로 근사합니다(기본색, 텍스처, 알파 모드, 양면). 림라이트와 셰이드 경계는 없습니다.
- **VRM**의 스키닝과 모프는 CPU에서 계산해 매 프레임 LowLevelMesh에 씁니다. 정점이 아주 많은 모델은 Release 빌드를 권장합니다.
- **얼굴 추적**은 ARKit(TrueDepth)을 쓰므로 Mac과 Vision Pro에서는 쓸 수 없습니다. 입술 랜드마크가 없어서 입 벌림은 `jawOpen`만으로 정합니다.
- **visionOS**: VRM은 창 안에 약 0.36 m 높이로 섭니다.

## 라이선스

- 코드: LivLiv Player와 같은 Apache License 2.0 (`livlivIOSPlayer/Resources/Legal/`)
- 동봉 캐릭터: Apache 라이선스가 **적용되지 않습니다**. 비상업 용도에 한하며 출처를 밝혀야 합니다. Kujira와 Kujira Q는 CC BY-NC-SA 4.0이고, Pen에는 어떤 권리도 주어지지 않습니다. 배포하기 전에 앱 안의 「라이선스와 상표」를 읽어 주세요.
- LivLiv 이름과 로고는 어느 라이선스에도 포함되지 않습니다.
