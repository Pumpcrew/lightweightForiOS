# livlivIOSPlayer

[LivLiv Player](https://github.com/livliv-dev/player)(웹용 2.5D 캐릭터 플레이어, TypeScript/WebGL2)를 **iOS · macOS · visionOS 네이티브 앱**으로 옮긴 프로젝트입니다. 렌더러는 **Metal**, VRM은 **RealityKit** 위에 직접 구현한 glTF/VRM 로더로 그립니다.

- 최소 버전: iOS 18, macOS 15, visionOS 2 (Xcode 16 이상, Swift 6 툴체인)
- 외부 의존성 없음. 앱 로직은 로컬 Swift Package(`Packages/LivLivKit`)에 있습니다.

## 빌드

1. `livlivIOSPlayer.xcodeproj`를 Xcode로 엽니다.
2. 실행 대상(destination)으로 iPhone/iPad(기기 또는 시뮬레이터), My Mac, Apple Vision Pro 중 하나를 고릅니다.
3. Run(⌘R)을 누릅니다. 서명은 Automatic(Team Y6L526TMB6)으로 설정되어 있습니다.

`LivLivCore`는 Debug에서도 `-O`로 빌드됩니다. 리그가 한 프레임에 수만 개의 정점을 움직이기 때문입니다(k01 기준 −Onone 약 17 ms, −O 약 2 ms).

## 구조

```
livlivIOSPlayer.xcodeproj      멀티플랫폼 앱 타깃 하나 (iphoneos, macosx, xros)
livlivIOSPlayer/               앱 (폴더 동기화 그룹)
  App/                         진입점, AppModel(로드 · 가져오기 · 립싱크 · 얼굴 추적 · 실패 처리)
  Views/                       화면, 설정, 오픈 소스 라이선스, 가져오기, TextView 실패 Alert
  Resources/Legal/             「라이선스와 상표」 문서, Apache-2.0 전문, NOTICE
  Assets.xcassets
Config/                        Info.plist(Documents 공유), macOS 샌드박스 entitlements
Packages/LivLivKit/            Swift Package
  Sources/LivLivCore/          순수 Swift(Foundation만 사용): 모델 형식 v3/v4, ZIP, 자동 리그 · 물리 · 키폼,
                               아이들 · 토크 · 액션, 립싱크 분석(엔벌로프 · 모음), 얼굴 → 파라미터 매핑,
                               glTF/VRM 0.x · 1.0 리더, VRM 포즈 · 스프링본 · 모프 · CPU 스키닝
  Sources/LivLivKit/           Apple 플랫폼: Metal 렌더러, RealityKit VRM 뷰, 이미지 디코딩, 워터마크,
                               마이크(AVAudioEngine), 음성 파일, ARKit 얼굴 추적, SwiftUI 뷰
  Sources/LivLivSamples/       동봉 캐릭터 21종 (별도 라이선스: Characters/LICENSE.md, CREDITS.md)
  Tests/LivLivCoreTests/       코어 테스트 (Linux · macOS에서 `swift test`)
```

### 원본 → 포팅 대응

| 원본 (TypeScript) | 포팅 (Swift) |
|---|---|
| `runtime/puppet.ts` (리그, 물리, 체인, 키폼, 그리기 순서) | `LivLivCore/Puppet.swift` (그리기 명령 목록 생성) + `LivLivKit/MetalRenderer.swift` (실행) |
| WebGL2 셰이더 · 스텐실 · 마스크 FBO | Metal 셰이더(런타임 컴파일), `MTLDepthStencilState`, 채널별 마스크 렌더 패스 |
| `runtime/format.ts`, `zip.ts` | `ModelFormat.swift`, `Keyforms.swift`, `Zip.swift`(deflate는 Compression 프레임워크) |
| `runtime/idle.ts`, `follow.ts`, `talk.ts`, `actions.ts`, `base.ts` | `LivelyIdle.swift`, `Motion.swift`, `Composer.swift` |
| `runtime/voice.ts`, `vowel.ts`, `speech.ts` | `Voice.swift` + `LivLivKit/LipSync.swift`(AVAudioEngine, AVAudioPlayer) |
| `runtime/tracking.ts` (MediaPipe) | `Composer.swift` FaceMapper + `LivLivKit/FaceTracking.swift`(ARKit, iOS TrueDepth) |
| `png.ts` | `CharacterStage.pngQuad` |
| `vrm.ts` (three.js + three-vrm) | `VRM/GLTF.swift`, `VRMModel.swift`, `VRMRig.swift` + `LivLivKit/VRMStageView.swift`(RealityKit LowLevelMesh) |
| `mark.ts`, `runtime/brand.ts` | `LivLivKit/Watermark.swift` (CoreGraphics) |

## 앱 기능

- **캐릭터 메뉴**: 동봉 캐릭터 21종
- **가져오기**: 앱의 Documents 폴더에 사용자가 넣은 폴더나 파일을 목록에서 고르면, 먼저 열 수 있는지 검사(`CharacterInspector`)한 뒤 로드합니다. 열 수 없으면 사유를 **UITextView/NSTextView로 된 Alert**에 보여 줍니다(선택 · 복사 가능).
  - iPhone/iPad/Vision Pro: 파일 앱 › 나의 iPhone › livlivIOSPlayer (`UIFileSharingEnabled`, `LSSupportsOpeningDocumentsInPlace`)
  - Mac: 가져오기 메뉴의 「Finder에서 Documents 폴더 열기」(샌드박스 컨테이너의 Documents)
  - 「다른 위치에서 선택…」으로 다른 곳에 있는 폴더나 파일도 열 수 있습니다(보안 범위 접근).
  - 지원 형식: LivLiv 모델 폴더(`model.json` + `textures/`), `.livliv`/`.zip`, `.vrm`/`.glb`(VRM 0.x/1.0), PNGTuber 폴더(`closed.png`, `open.png`, 선택: `blink.png`, `blink-open.png`, `name.txt`)
- **표정 · 액션 · 졸기**, 포인터(드래그/호버)를 따라보기, 탭하면 흔들리는 부분(체인)을 튕기기, 핀치 줌
- **립싱크**: 마이크, 음성 파일 / **얼굴 추적**: TrueDepth가 있는 iPhone·iPad
- **설정**: 움직임 · 해상도 · 얼굴 추적, **오픈 소스 라이선스** › 「라이선스와 상표」 문서와 원문

## 테스트

```sh
cd Packages/LivLivKit
swift test
```

Linux에서 실행해 확인한 것: 동봉 캐릭터 21종의 `model.json` 읽기, 각 캐릭터를 240프레임 재생(표정 · 액션 · 입 모양 · 홍채 스텐실 포함), 키폼(d03ft), 체인 튕기기, ZIP, 립싱크 분석, VRM 0.x/1.0 읽기와 거부 사례(메시 없음, Draco, 너무 큰 그림), 스키닝 · 모프 · 스프링본.

## 알려진 차이와 한계

- **MToon**: RealityKit의 Unlit 머티리얼로 근사합니다(기본색 · 텍스처 · 알파 모드 · 양면). 림라이트와 셰이드 경계는 없습니다.
- **VRM 렌더링**: 스키닝 · 모프는 CPU에서 계산해 매 프레임 LowLevelMesh에 씁니다. 정점이 매우 많은 모델은 Release 빌드를 권장합니다.
- **얼굴 추적**: ARKit(TrueDepth) 전용이라 Mac과 Vision Pro에서는 지원하지 않습니다. MediaPipe와 달리 입술 랜드마크가 없어서 입 벌림은 `jawOpen`만으로 정합니다.
- **visionOS**: VRM은 창 안에 약 0.36 m 높이로 놓입니다.
- 이 저장소는 Linux에서 코어 테스트와 Swift 구문 검사만 거쳤습니다. Apple SDK로 처음 빌드할 때 경고나 사소한 API 차이가 나올 수 있습니다.

## 라이선스

- 코드: LivLiv Player의 Apache License 2.0을 따릅니다(`livlivIOSPlayer/Resources/Legal/`).
- 동봉 캐릭터: Apache 라이선스가 **적용되지 않습니다**. 비상업 용도에 한하며 출처 표기가 필요합니다. Kujira·Kujira Q는 CC BY-NC-SA 4.0이고, Pen에는 어떤 권리도 부여되지 않습니다. 앱을 배포하기 전에 앱 안의 「라이선스와 상표」 문서를 확인하세요.
- "LivLiv" 이름과 로고는 어느 라이선스에도 포함되지 않습니다.
