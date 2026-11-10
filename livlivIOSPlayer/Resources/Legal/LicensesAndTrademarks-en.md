# Licenses and Trademarks

This page sums up the licenses of the code and characters in livlivIOSPlayer, and the trademarks involved. Each original text is linked below this page. Where this summary and an original differ, the original applies.

## 1. This app's code

- livlivIOSPlayer is a Swift port of LivLiv Player (https://github.com/livliv-dev/player, version 0.3.0, commit 011b1f5).
- The original LivLiv Player code is distributed under the **Apache License 2.0**. Copyright 2026 LivLiv. Under its terms, this app comes with the license text and the NOTICE.
- **Notice of changes (Apache License 2.0, section 4):** the original's TypeScript runtime (the model format, the automatic rig, physics, idle motion, lip-sync analysis, expressions and actions) was rewritten in Swift. The WebGL2 renderer was reimplemented on Metal. VRM drawing, which used three.js and @pixiv/three-vrm, was replaced by our own glTF/VRM loader on RealityKit. MediaPipe face tracking was replaced by ARKit face tracking.
- The Apple frameworks this app uses (SwiftUI, Metal, RealityKit, AVFoundation, ARKit, ImageIO and others) are part of Apple's SDK, not separate open source components. The app includes no third-party open source libraries.

## 2. Bundled characters (21)

The bundled characters are **not covered by the Apache License.**

### LivLiv Featured Characters License 1.0 (18 characters: all but Kujira, Kujira Q and Pen)

- **Allowed:** free non-commercial use (personal streams, videos, demos, learning, tests, research, open source projects) and changes for your own use
- **Credit required:** "Characters: LivLiv (livliv.ai)"
- **Not allowed:** selling, distributing the characters or their textures on their own (changed versions included), commercial use (ads, product promotion, paid apps or services, merchandise), training or fine-tuning AI models, use in sexual, violent, discriminatory, fraudulent or political-propaganda content
- **Redistribution:** only unchanged, with the license, together with the LivLiv Stage or LivLiv Player repository (or a fork). To distribute this app (the App Store, say), or to put the characters in an app with a price, ads or in-app purchases, **get permission from LivLiv (admin@livliv.ai) first, or take the bundled characters out.**
- **Mascot:** Nana (d03, d03ft) is LivLiv's mascot. Nana may not represent you or any other product, service or brand, nor suggest that LivLiv endorses or sponsors you.

### Characters from other people's work

- **Kujira (p01), Kujira Q (p02):** based on the community character 「鲸鱼娘」 (original character 溟月 by 上善无形, maid design by ZipZipPipe). They are under **CC BY-NC-SA 4.0**. Credit: "Kujira: 上善无形, ZipZipPipe (CC BY-NC-SA 4.0); model by LivLiv". An unofficial community character, not connected with DeepSeek.
- **Pen (p03):** based on the fan character 「咕咕嘎嘎」 (by 贱兔死顺盖, after the Administrator in Arknights: Endfield, Hypergryph). **No license covers it; LivLiv holds no rights in this character and grants none.** Leave it out of builds you distribute publicly.

### The watermark

The LivLiv mark in the bottom-right corner of the bundled characters is asked for by their packages and is a condition of their license. This app draws the mark a package asks for, and never adds it to one that does not. Removing it breaks the license.

## 3. Trademarks

- The **"LivLiv"** name and logos are covered by neither the Apache License nor the characters' license. They may not be used in an app's name, icon, store listing or marketing without LivLiv's permission. "livlivIOSPlayer" is a development project name: before distributing the app publicly, give it a name without the LivLiv trademark.
- **"Live2D"** is a trademark of Live2D Inc. LivLiv and this app are not affiliated with Live2D Inc., use no Live2D software or Cubism SDK, and read no .moc3 or .cmo3 files.
- **VRM** is a 3D avatar file format maintained by the VRM Consortium. This app reads files as the VRM 0.x and 1.0 specifications describe, and is not affiliated with the VRM Consortium.
- Apple, iPhone, iPad, Mac, Apple Vision Pro, iOS, macOS, visionOS, Metal, RealityKit and ARKit are trademarks of Apple Inc.
- Other company and product names are trademarks of their respective owners.

## 4. Characters you add

- A LivLiv model you add follows the author and terms in its meta.author and meta.license. They show in this app's character info.
- A VRM you add follows the terms of use in the file (who may use it, commercial use, redistribution, modification and so on). They show in the character info.
- When you show a character made with LivLiv (livliv.ai) in public, say that AI was used to make it, and don't present it as hand-drawn or hand-rigged.

## 5. Privacy

- Microphone sound and camera (face tracking) pictures are analyzed on the device only: never stored, never sent.
- This app makes no network connections. It reads only the characters it ships with and the files you choose.

## 6. Original texts

- LivLiv Player — the Apache License 2.0 in full
- LivLiv Player — NOTICE
- LivLiv Featured Characters License (characters/LICENSE.md)
- Character sources and credits (characters/CREDITS.md)
