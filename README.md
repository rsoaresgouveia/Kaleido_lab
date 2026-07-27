# Kaleido Lab

> A Flutter playground for building and trying out isolated UI and platform
> features, each reachable from a single gallery home screen.

[![CI](https://github.com/rsoaresgouveia/Kaleido_lab/actions/workflows/ci.yml/badge.svg)](https://github.com/rsoaresgouveia/Kaleido_lab/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Stack](https://img.shields.io/badge/stack-Flutter-02569B)

---

## Table of contents

- [Overview](#overview)
- [Features](#features)
- [Tech stack](#tech-stack)
- [Getting started](#getting-started)
- [Project structure](#project-structure)
- [Architecture](#architecture)
- [Testing](#testing)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

## Overview

Kaleido Lab is a sandbox application. Its home screen is a gallery that links to
self-contained feature demos, so each experiment lives in isolation and can be
opened, tested, and iterated on without disturbing the rest of the app.

The project doubles as a reference for a clean, production-shaped Flutter setup:
a layered architecture, internationalization, theming, declarative navigation,
and persisted user preferences are all wired up from the first commit. New
feature demos plug into that foundation.

## Features

- **Face capture** — a guided, ID-style capture flow (the first feature study).
  Live front-camera detection with an animated alignment frame, real-time
  guidance, and automatic capture once the shot is compliant. See
  [Feature study: face capture](#feature-study-face-capture).
- **Gallery home** — a single entry point that lists the available feature demos.
- **Theming** — Material 3 light/dark themes derived from one seed color, with a
  System / Light / Dark switch.
- **Internationalization** — English and Brazilian Portuguese, backed by ARB
  files and `flutter gen-l10n`, switchable at runtime or following the device.
- **Persisted preferences** — theme and language choices survive restarts via
  `shared_preferences`.
- **Declarative navigation** — routing handled by `go_router`.

## Tech stack

- **Language / runtime:** Flutter (stable) / Dart 3
- **State management:** Riverpod
- **Routing:** go_router
- **Localization:** `flutter_localizations` + `gen_l10n` (ARB)
- **Persistence:** shared_preferences
- **On-device ML:** `google_mlkit_face_detection`
- **Camera & media:** `camera`, `image_picker`
- **Testing:** flutter test
- **CI:** GitHub Actions

## Getting started

### Prerequisites

- Flutter SDK (stable channel)

### Installation

```bash
flutter pub get
```

### Run

```bash
flutter run
```

## Project structure

```
lib/
├── main.dart                     # bootstrap: load prefs, install ProviderScope
├── app/
│   ├── app.dart                  # MaterialApp.router; wires theme, locale, routes
│   └── router/                   # go_router config and route constants
├── core/
│   ├── localization/             # l10n helper + generated localizations
│   └── theme/                    # Material 3 light/dark theme
└── features/
    ├── home/                     # the gallery home screen
    │   └── presentation/
    └── settings/                 # theme + language, as a clean-architecture slice
        ├── data/                 # data sources + repository implementation
        ├── domain/               # entities + repository contract
        └── presentation/         # controller, providers, page
```

## Architecture

Each feature is organized into three layers:

- **domain** — framework-agnostic entities and repository interfaces (no Flutter
  imports).
- **data** — data sources and repository implementations that fulfill the domain
  contracts.
- **presentation** — Riverpod controllers/providers and the Flutter widgets.

The `settings` feature is a complete vertical slice through all three layers and
serves as the template every new feature demo follows.

## Testing

Tests must pass before every commit (see [CONTRIBUTING.md](CONTRIBUTING.md)).

```bash
flutter analyze
flutter test
```

## Feature study: face capture

A guided flow that produces an ID-style portrait and checks it on-device with
ML Kit face detection. It has three screens — a **guide**, a **live camera** with
an alignment oval and a manual shutter, and a **review** of the result. A
camera-free **"analyze a photo"** mode runs the same rules on a gallery image.

Rules evaluated by the pure `FaceComplianceEvaluator` (fully unit-tested):

| Check | Signal used |
|-------|-------------|
| Single face | detected face count |
| Framing | face-box size and distance from center |
| Facing forward | head Euler angles (yaw / pitch / roll) |
| Eyes open | left/right eye-open probability |
| Neutral expression | smiling probability |
| Lighting | average frame luminance |

### Live guidance vs. the still gate

The **decision is made on the captured still**, not the live preview. Mapping
ML Kit's camera-stream coordinates to the screen is device-specific (sensor
orientation, resolution, mirroring, crop), so the live preview uses only the
**lenient**, rotation-invariant checks (`ComplianceThresholds.live`) to *guide*
the user — positional centering is disabled there. The captured photo is then
re-analyzed with the **strict**, authoritative rules (`ComplianceThresholds.still`);
because a saved image is upright, its coordinates are reliable on every device.
Only a photo that passes the still gate can be accepted. This split is what makes
the acceptance decision **device-agnostic** and portable.

**Known limitations.** ML Kit does not classify accessories (glasses, hats), so
"remove accessories" is guidance rather than an automated check, and it provides
no liveness / anti-spoofing (use a dedicated SDK if that is required). Lighting is
approximated from luminance. The **live camera needs a physical device**. The
transform used only for the live preview still needs validation across the target
device matrix.

## Roadmap

- [x] Add the first feature demo (face capture) and surface it on the home gallery.
- [ ] Grow the gallery with additional self-contained feature demos.
- [ ] Add golden tests for the shared theme.

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for the
commit convention, branching model, pull-request flow, and bug-report process.

## License

Released under the [MIT License](LICENSE).
