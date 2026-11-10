# 라이선스와 상표

이 문서는 livlivIOSPlayer에 들어 있는 코드와 캐릭터의 라이선스, 그리고 관련 상표를 정리한 것입니다. 각 원문은 이 화면 아래의 링크에서 볼 수 있습니다. 원문과 이 요약이 다르면 원문이 우선합니다.

## 1. 이 앱의 코드

- livlivIOSPlayer는 LivLiv Player(https://github.com/livliv-dev/player, 버전 0.3.0, 커밋 011b1f5)를 Swift로 포팅한 앱입니다.
- 원본 LivLiv Player의 코드는 **Apache License 2.0**으로 배포됩니다. Copyright 2026 LivLiv. 이 앱은 그 조건에 따라 라이선스 전문과 NOTICE를 함께 제공합니다.
- **변경 사항 고지(Apache License 2.0 제4조):** 원본의 TypeScript 런타임(모델 형식, 자동 리그, 물리, 아이들 모션, 립싱크 분석, 표정, 액션)을 Swift로 옮겼습니다. WebGL2 렌더러는 Metal로 다시 구현했습니다. three.js와 @pixiv/three-vrm에 의존하던 VRM 표시는 자체 glTF/VRM 로더와 RealityKit 기반 구현으로 바꿨습니다. MediaPipe 얼굴 추적은 ARKit 얼굴 추적으로 바꿨습니다.
- 이 앱이 쓰는 Apple 프레임워크(SwiftUI, Metal, RealityKit, AVFoundation, ARKit, ImageIO 등)는 Apple SDK의 일부이며 별도의 오픈 소스 구성요소가 아닙니다. 외부 오픈 소스 라이브러리는 포함하지 않습니다.

## 2. 동봉된 캐릭터 (21종)

동봉된 캐릭터에는 **Apache License가 적용되지 않습니다.**

### LivLiv Featured Characters License 1.0 (Kujira, Kujira Q, Pen을 제외한 18종)

- **허용:** 비상업적 용도의 무료 사용(개인 방송, 영상, 시연, 학습, 테스트, 연구, 오픈 소스 프로젝트)과 개인 용도의 수정
- **출처 표기 필수:** "Characters: LivLiv (livliv.ai)" (캐릭터: LivLiv(livliv.ai))
- **금지:** 판매, 캐릭터나 텍스처의 단독 재배포(수정본 포함), 상업적 이용(광고, 제품 홍보, 유료 앱이나 서비스, 굿즈 등), AI 모델 학습이나 미세 조정, 성인·폭력·차별·사기·정치 선전 콘텐츠에 사용
- **재배포:** LivLiv Stage나 LivLiv Player 저장소(또는 그 포크)와 함께, 라이선스를 붙여 원본 그대로 배포하는 경우만 허용됩니다. 이 앱을 App Store 등으로 배포하거나 유료·광고·인앱 결제가 있는 앱에 넣으려면, **배포 전에 LivLiv(admin@livliv.ai)의 허락을 받거나 동봉 캐릭터를 빼야 합니다.**
- **마스코트:** Nana(d03, d03ft)는 LivLiv의 마스코트입니다. 자신이나 다른 제품·서비스·브랜드의 이미지로 쓸 수 없고, LivLiv이 후원하거나 보증하는 것처럼 보이게 해서도 안 됩니다.

### 다른 사람의 작품에서 온 캐릭터

- **Kujira(p01), Kujira Q(p02):** 커뮤니티 캐릭터 「鲸鱼娘」 기반입니다(원작 캐릭터 溟月: 上善无形, 메이드 디자인: ZipZipPipe). **CC BY-NC-SA 4.0**이 적용됩니다. 표기: "Kujira: 上善无形, ZipZipPipe (CC BY-NC-SA 4.0); model by LivLiv". 비공식 커뮤니티 캐릭터이며 DeepSeek과 관련이 없습니다.
- **Pen(p03):** 팬 캐릭터 「咕咕嘎嘎」(贱兔死顺盖 작, 『명일방주: 엔드필드』(Hypergryph)의 관리자 기반) 기반입니다. **어떤 라이선스도 적용되지 않으며, LivLiv은 이 캐릭터에 대해 아무 권리도 갖지 않고 부여하지도 않습니다.** 공개 배포하는 빌드에서는 빼는 것을 권장합니다.

### 워터마크

동봉 캐릭터 화면 오른쪽 아래의 LivLiv 마크는 패키지가 요청한 것이고 라이선스의 조건입니다. 이 앱은 패키지가 요청한 마크를 그대로 그리며, 요청하지 않은 패키지에는 추가하지 않습니다. 마크를 지우는 것은 라이선스 위반입니다.

## 3. 상표

- **"LivLiv"** 이름과 로고는 Apache License에도, 캐릭터 라이선스에도 포함되지 않습니다. LivLiv의 허락 없이 앱 이름, 아이콘, 스토어 등록 정보, 마케팅에 쓸 수 없습니다. 'livlivIOSPlayer'는 개발용 프로젝트 이름입니다. 공개 배포 전에는 LivLiv 상표가 들어가지 않은 이름으로 바꾸는 것을 권장합니다.
- **"Live2D"**는 Live2D Inc.의 상표입니다. LivLiv와 이 앱은 Live2D Inc.와 관계가 없고, Live2D 소프트웨어나 Cubism SDK를 쓰지 않으며, .moc3·.cmo3 파일을 읽지 않습니다.
- **VRM**은 VRM 컨소시엄이 관리하는 3D 아바타 파일 형식입니다. 이 앱은 VRM 0.x와 1.0 사양에 따라 파일을 읽을 뿐이며, VRM 컨소시엄과 관계가 없습니다.
- Apple, iPhone, iPad, Mac, Apple Vision Pro, iOS, macOS, visionOS, Metal, RealityKit, ARKit은 Apple Inc.의 상표입니다.
- 그 밖의 회사명과 제품명은 각 소유자의 상표입니다.

## 4. 사용자가 가져온 캐릭터

- 가져온 LivLiv 모델은 meta.author와 meta.license에 적힌 제작자와 이용 조건을 따라야 합니다. 이 앱의 캐릭터 정보 화면에서 확인할 수 있습니다.
- 가져온 VRM은 파일에 들어 있는 이용 조건(이용 허가 범위, 상업적 이용, 재배포, 개변 등)을 따라야 합니다. 캐릭터 정보 화면에 표시됩니다.
- LivLiv(livliv.ai)로 만든 캐릭터를 공개할 때는 AI를 사용했다는 사실을 밝히고, 손으로 그리거나 직접 리깅한 것처럼 표시하지 마세요.

## 5. 개인정보

- 마이크 소리와 카메라(얼굴 추적) 영상은 기기 안에서만 분석되며, 저장하거나 외부로 보내지 않습니다.
- 이 앱은 네트워크에 접속하지 않습니다. 캐릭터는 앱에 들어 있는 것과 사용자가 직접 고른 파일만 읽습니다.

## 6. 원문

- LivLiv Player — Apache License 2.0 전문
- LivLiv Player — NOTICE
- LivLiv Featured Characters License (characters/LICENSE.md)
- 캐릭터 출처와 크레딧 (characters/CREDITS.md)
