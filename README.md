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

- **Gallery home** — a single entry point that will list every feature demo
  (currently empty by design; demos are added incrementally).
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

## Roadmap

- [ ] Add the first feature demo and surface it on the gallery home.
- [ ] Grow the gallery with additional self-contained feature demos.
- [ ] Add golden tests for the shared theme.

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for the
commit convention, branching model, pull-request flow, and bug-report process.

## License

Released under the [MIT License](LICENSE).
