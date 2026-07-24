# Changelog

All notable changes to this project are documented in this file. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.2.1]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.2.1
[0.2.0]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.2.0
[0.1.1]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.1.1
[0.1.0]: https://github.com/rsoaresgouveia/Kaleido_lab/releases/tag/v0.1.0
