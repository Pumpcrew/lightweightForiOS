# livlivIOSPlayer

[English](../../README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-Hans.md) · [繁體中文](README.zh-Hant.md) · [繁體中文（香港）](README.zh-HK.md) · [Español](README.es.md) · [Español (Latinoamérica)](README.es-419.md) · [Français](README.fr.md) · [Français (Canada)](README.fr-CA.md) · [Deutsch](README.de.md) · [Italiano](README.it.md) · [Português (Brasil)](README.pt-BR.md) · [Português (Portugal)](README.pt-PT.md) · [Nederlands](README.nl.md) · [Svenska](README.sv.md) · [Dansk](README.da.md) · [Norsk bokmål](README.nb.md) · [Suomi](README.fi.md) · **Polski** · [Čeština](README.cs.md) · [Slovenčina](README.sk.md) · [Slovenščina](README.sl.md) · [Hrvatski](README.hr.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [Български](README.bg.md) · [Қазақ тілі](README.kk.md) · [Ελληνικά](README.el.md) · [Română](README.ro.md) · [Magyar](README.hu.md) · [Lietuvių](README.lt.md) · [Türkçe](README.tr.md) · [Català](README.ca.md) · [العربية](README.ar.md) · [עברית](README.he.md) · [اردو](README.ur.md) · [हिन्दी](README.hi.md) · [বাংলা](README.bn.md) · [ગુજરાતી](README.gu.md) · [ಕನ್ನಡ](README.kn.md) · [മലയാളം](README.ml.md) · [मराठी](README.mr.md) · [ଓଡ଼ିଆ](README.or.md) · [ਪੰਜਾਬੀ](README.pa.md) · [தமிழ்](README.ta.md) · [తెలుగు](README.te.md) · [ไทย](README.th.md) · [Tiếng Việt](README.vi.md) · [Bahasa Indonesia](README.id.md) · [Bahasa Melayu](README.ms.md)

Ten projekt przenosi [LivLiv Player](https://github.com/livliv-dev/player), odtwarzacz postaci 2.5D dla przeglądarki (TypeScript/WebGL2), do **natywnej aplikacji na iOS, macOS i visionOS**. Postacie są rysowane przez **Metal**, a awatary VRM przez napisany dla tego projektu loader glTF/VRM oparty na **RealityKit**.

## Wymagania

- iOS 18, macOS 15 lub visionOS 2 albo nowszy (Xcode 16 lub nowszy, narzędzia Swift 6)
- Brak zależności zewnętrznych. Logika aplikacji znajduje się w lokalnym pakiecie Swift (`Packages/LivLivKit`).

## Budowanie

1. Otwórz `livlivIOSPlayer.xcodeproj` w Xcode.
2. W Signing & Capabilities wybierz własny Team i w razie potrzeby zmień identyfikator pakietu.
3. Jako cel wybierz iPhone’a lub iPada (urządzenie albo symulator), My Mac lub Apple Vision Pro, a potem naciśnij Run (⌘R).

`LivLivCore` jest budowany z `-O` nawet w Debug, bo rig przesuwa w każdej klatce dziesiątki tysięcy wierzchołków (k01: około 17 ms na klatkę przy `-Onone`, około 2 ms przy `-O`).

## Funkcje

- **Postacie**: 21 dołączonych postaci
- **Importuj**: wybierz folder lub plik umieszczony w folderze Documents aplikacji. Aplikacja najpierw sprawdza, czy może go otworzyć, a potem go wczytuje. Jeśli nie może, alert pokazuje powód w widoku tekstu, który można zaznaczyć i skopiować.
- Folder Documents: na iPhonie, iPadzie i Vision Pro w Pliki › Na moim iPhonie › livlivIOSPlayer; na Macu przez „Otwórz folder Documents w Finderze” w Importuj. „Wybierz z innego miejsca…” otwiera folder lub plik w innym miejscu.
- Miny, akcje i drzemka. Postać podąża za wskaźnikiem, kołyszące się części podskakują po dotknięciu, a gestem szczypania można powiększać.
- **Synchronizacja ust** z mikrofonu lub pliku audio oraz **śledzenie twarzy** na iPhonie lub iPadzie z TrueDepth
- **Ustawienia**: ruch, rozdzielczość, śledzenie twarzy oraz Licencje open source › „Licencje i znaki towarowe”

## Obsługiwane formaty

- Folder modelu LivLiv (`model.json` + `textures/`), `.livliv` / `.zip`
- `.vrm` / `.glb` (VRM 0.x / 1.0), także pliki wyeksportowane przez VRM Add-on dla Blendera
- Folder PNGTuber: `closed.png`, `open.png` (opcjonalnie: `blink.png`, `blink-open.png`, `name.txt`)

Plik, którego nie da się odtworzyć (VRM bez siatki, kompresja Draco / Meshopt / KTX2, zbyt duże obrazy), jest odrzucany z podaniem powodu.

## Lokalizacja

- Teksty aplikacji są dostępne w 50 językach, w katalogach ciągów (`livlivIOSPlayer/Localizable.xcstrings`, `InfoPlist.xcstrings`). Językiem programowania jest angielski, którego używają też regionalne odmiany angielskiego.
- Dokument „Licencje i znaki towarowe” jest po koreańsku na urządzeniach koreańskojęzycznych, a w pozostałych po angielsku. Nazwy postaci, informacje o autorach i oryginalne teksty licencji nie są tłumaczone.
- Ten README jest dostępny w tych samych językach (linki na górze). Tłumaczenia nie zostały jeszcze sprawdzone przez rodzimych użytkowników, więc poprawki są mile widziane.

## Struktura projektu

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

## Oryginał → port

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

## Testy

```sh
cd Packages/LivLivKit
swift test
```

Sprawdzone na Linuksie: wczytanie 21 dołączonych postaci i po 240 klatek każdej (miny, akcje, usta, stencil tęczówki), keyformy, sprężynowanie łańcuchów, ZIP, analiza synchronizacji ust, wczytywanie i odrzucanie VRM 0.x / 1.0, skinning, morphy i spring bones oraz to, co zapisuje VRM Add-on dla Blendera (kompresja wymieniona, ale nieużyta, `KHR_texture_transform`, samplery).

## Znane różnice i ograniczenia

- **MToon** jest przybliżany nieoświetlonym materiałem RealityKit (kolor bazowy, tekstura, tryb alfa, dwustronność). Nie ma światła krawędzi ani granicy cienia.
- W **VRM** skinning i morphy są liczone na CPU i co klatkę zapisywane do LowLevelMesh. Dla modeli z bardzo wieloma wierzchołkami zalecana jest kompilacja Release.
- **Śledzenie twarzy** korzysta z ARKit (TrueDepth), więc nie działa na Macu ani na Vision Pro. Bez punktów charakterystycznych ust otwarcie ust wynika tylko z `jawOpen`.
- **visionOS**: VRM ma w oknie około 0,36 m wysokości.

## Licencja

- Kod: Apache License 2.0, tak jak LivLiv Player (`livlivIOSPlayer/Resources/Legal/`).
- Dołączone postacie: licencja Apache **nie** ma zastosowania. Wyłącznie użytek niekomercyjny, z podaniem autora. Kujira i Kujira Q są na licencji CC BY-NC-SA 4.0, a do Pen nie przyznano żadnych praw. Przed rozpowszechnianiem przeczytaj „Licencje i znaki towarowe” w aplikacji.
- Nazwa i logo LivLiv nie są objęte żadną licencją.
