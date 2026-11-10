# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · **日本語** · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · [Polski](README.pl.md) · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Web 向けの 2.5D キャラクタープレイヤー [LivLiv Player](https://github.com/livliv-dev/player)（TypeScript/WebGL2）を **iOS・macOS・visionOS のネイティブアプリ**に移植したプロジェクトです。キャラクターは **Metal** で、VRM アバターはこのプロジェクトのために **RealityKit** 上に作った glTF/VRM ローダーで描画します。

## 動作環境

- iOS 18、macOS 15、visionOS 2 以降（Xcode 16 以降、Swift 6 ツールチェーン）
- 外部依存はありません。アプリのロジックはローカルの Swift パッケージ（`Packages/LivLivKit`）にあります。

## ビルド

1. Xcode で `livlivIOSPlayer.xcodeproj` を開きます。
2. Signing & Capabilities で自分の Team を選び、必要ならバンドル ID を変更します。
3. 実行先に iPhone または iPad（実機かシミュレータ）、My Mac、Apple Vision Pro のいずれかを選び、Run（⌘R）を押します。

`LivLivCore` は Debug でも `-O` でビルドします。リグが 1 フレームで数万の頂点を動かすためです（k01 で `-Onone` は 1 フレーム約 17 ms、`-O` は約 2 ms）。

## 機能

- **キャラクター**: 同梱キャラクター 21 体
- **読み込み**: アプリの Documents フォルダに入れたフォルダやファイルを選ぶと、開けるかどうかを先に確認してから読み込みます。開けない場合は、選択・コピーできるテキストビューの Alert に理由を表示します。
- Documents フォルダの場所: iPhone・iPad・Vision Pro では ファイル App › このiPhone内 › livlivIOSPlayer、Mac では 読み込み の「Finder で Documents フォルダを開く」。「ほかの場所から選択…」で別の場所のフォルダやファイルも開けます。
- 表情、アクション、居眠り。キャラクターはポインタを目で追い、タップすると揺れる部分が弾み、ピンチで拡大できます。
- マイクや音声ファイルによる**リップシンク**、TrueDepth 搭載の iPhone・iPad での**フェイストラッキング**
- **設定**: 動き、解像度、フェイストラッキング、オープンソースライセンス ›「ライセンスと商標」

## 対応形式

- LivLiv モデルフォルダ（`model.json` + `textures/`）、`.livliv` / `.zip`
- `.vrm` / `.glb`（VRM 0.x / 1.0）。Blender 用 VRM Add-on で書き出したファイルを含む
- PNGTuber フォルダ: `closed.png`、`open.png`（任意: `blink.png`、`blink-open.png`、`name.txt`）

再生できないファイル（メッシュのない VRM、Draco / Meshopt / KTX2 圧縮、大きすぎる画像）は理由を示して拒否します。

## 多言語対応

- アプリのテキストは 50 言語で、String Catalog（`livlivIOSPlayer/Localizable.xcstrings`、`InfoPlist.xcstrings`）に入っています。開発言語は英語で、地域別の英語も英語を使います。
- 「ライセンスと商標」の文書は、韓国語の端末では韓国語、それ以外では英語で表示されます。キャラクター名、クレジット、原文のライセンスは翻訳しません。
- この README も同じ言語で用意しています（冒頭のリンク）。翻訳はまだネイティブスピーカーの確認を受けていないため、修正の提案を歓迎します。

## 構成

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

## 元のコード → 移植先

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

## テスト

```sh
cd Packages/LivLivKit
swift test
```

Linux で確認した内容: 同梱キャラクター 21 体の読み込みと各 240 フレームの再生（表情、アクション、口、虹彩のステンシル）、キーフォーム、チェーンの弾み、ZIP、リップシンク解析、VRM 0.x / 1.0 の読み込みと拒否、スキニング・モーフ・スプリングボーン、Blender 用 VRM Add-on が書き出す内容（名前だけで使われていない圧縮、`KHR_texture_transform`、サンプラー）。

## 既知の違いと制限

- **MToon** は RealityKit の Unlit マテリアルで近似します（基本色、テクスチャ、アルファモード、両面）。リムライトと影の境界はありません。
- **VRM** のスキニングとモーフは CPU で計算し、毎フレーム LowLevelMesh に書き込みます。頂点がとても多いモデルには Release ビルドをおすすめします。
- **フェイストラッキング**は ARKit（TrueDepth）を使うため、Mac と Vision Pro では使えません。唇のランドマークがないため、口の開きは `jawOpen` だけで決めます。
- **visionOS**: VRM はウインドウ内に高さ約 0.36 m で立ちます。

## ライセンス

- コード: LivLiv Player と同じ Apache License 2.0（`livlivIOSPlayer/Resources/Legal/`）
- 同梱キャラクター: Apache ライセンスは**適用されません**。非商用に限り、クレジット表記が必要です。Kujira と Kujira Q は CC BY-NC-SA 4.0 で、Pen にはいかなる権利も与えられていません。配布する前にアプリ内の「ライセンスと商標」をお読みください。
- LivLiv の名前とロゴはどのライセンスにも含まれません。
