# Changelog

All notable changes to this project are documented in this file. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.2] - 2026-07-27

### Changed

- The home gallery now lays out features as a grid of square tiles (icon + name)
  instead of a vertical list.

## [0.3.1] - 2026-07-27

### Added

- Still-photo gate now enforces the access-control photo requirements: a minimum
  face size in pixels and at least a 10% margin around the face (whole face
  comfortably in frame), on top of single face, frontal, centered, and lighting.

### Changed

- Capture guide rewritten to the access-control best practices (≈60 cm distance,
  centered and facing the camera, even lighting, plain background, no cap/mask/
  sunglasses; prescription glasses allowed).

## [0.3.0] - 2026-07-27

### Changed

- Compliance is now decided on the **captured still**, not the live camera frame.
  The live preview uses lenient, rotation-invariant checks to guide the user
  (positional centering disabled — camera-stream coordinates are device-specific);
  the captured photo is re-checked with strict rules whose coordinates are
  reliable on every device. Acceptance ("Use this photo") is gated on that
  still result. This makes the accept/reject decision device-agnostic.

## [0.2.4] - 2026-07-27

### Added

- Manual shutter: once the capture is compliant for ~1.5s, a "Take photo" button
  appears instead of auto-capturing.

### Fixed

- Captured/gallery photos are now detected regardless of EXIF orientation (the
  front-camera JPEG previously came in rotated and was reported as "no face").

### Changed

- Framing is judged by face size only; on-device centering from ML Kit's box
  proved unreliable without per-device preview-coordinate calibration, so the
  user aligns their face in the on-screen oval instead.

## [0.2.3] - 2026-07-24

### Added

- `scripts/clean.sh`: a total cleanup + rebuild helper (Flutter/iOS/Android
  artifacts and caches, reinstall dependencies, regenerate code). Uses the
  FVM-pinned SDK and auto-runs `build_runner` if the project ever adopts it.
- `.vscode/` settings pointing the Dart/Flutter extension at the FVM SDK, plus
  debug/profile/release launch configs.

### Fixed

- Sync the iOS project for Flutter 3.44's Swift Package Manager migration
  (`camera`, `image_picker`, and `shared_preferences` now resolve via SPM; ML Kit
  stays on CocoaPods), so device builds succeed on 3.44.8.

## [0.2.2] - 2026-07-24

### Changed

- Adopt Flutter 3.44.8 (Dart 3.12), pinned per-project with FVM (`.fvmrc`). CI
  now builds against the same version.

## [0.2.1] - 2026-07-23

### Fixed

- iOS build with ML Kit: link CocoaPods statically (`use_frameworks! :linkage =>
  :static`) and raise the deployment target to 15.5, resolving the
  `Module 'camera_avfoundation' not found` error when building for a device.

## [0.2.0] - 2026-07-23

### Added

- Face capture feature: a guided, ID-style capture flow with on-device ML Kit
  face detection, an animated alignment frame, real-time guidance, and automatic
  capture once the shot is compliant.
- A camera-free "analyze a photo" mode that runs the same rules on an image from
  the gallery.
- Pure `FaceComplianceEvaluator` covering single face, framing, frontal pose,
  eyes open, neutral expression, and lighting — fully unit-tested.
- Home gallery now lists available feature demos.
- English and Brazilian Portuguese strings for the whole feature.

## [0.1.1] - 2026-07-23

### Changed

- CI now pins the Flutter version for reproducible runs, cancels superseded runs
  via a concurrency group, and can be triggered manually (`workflow_dispatch`).

## [0.1.0] - 2026-07-23

### Added

- Application scaffold with a layered (clean-architecture) structure.
- Material 3 theming with System / Light / Dark modes.
- Internationalization for English and Brazilian Portuguese (ARB + gen_l10n).
- Declarative navigation with `go_router`.
- Settings screen to switch theme and language, persisted with
  `shared_preferences`.
- Gallery home screen (empty, ready to host feature demos).
- Unit and widget tests, plus a GitHub Actions CI workflow.

[0.3.2]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.3.2
[0.3.1]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.3.1
[0.3.0]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.3.0
[0.2.4]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.2.4
[0.2.3]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.2.3
[0.2.2]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.2.2
[0.2.1]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.2.1
[0.2.0]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.2.0
[0.1.1]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.1.1
[0.1.0]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.1.0
