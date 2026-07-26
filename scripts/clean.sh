#!/usr/bin/env bash
#
# Total project cleanup + rebuild for Kaleido Lab.
#
# Wipes Flutter / iOS / Android build artifacts and caches, then reinstalls
# dependencies and regenerates generated code (localizations, and build_runner
# output if the project ever depends on it). Uses the FVM-pinned Flutter SDK
# when available.
#
# Usage:
#   ./scripts/clean.sh
#
set -euo pipefail

# Resolve the project root (this script lives in <root>/scripts).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Prefer the FVM-pinned SDK; fall back to a global install.
if command -v fvm >/dev/null 2>&1 && [ -f "$ROOT/.fvmrc" ]; then
  FLUTTER=(fvm flutter)
  DART=(fvm dart)
else
  FLUTTER=(flutter)
  DART=(dart)
fi

step() { printf '\n\033[1;36m▶ %s\033[0m\n' "$1"; }

step "flutter clean"
"${FLUTTER[@]}" clean

step "Removing Dart/Flutter build artifacts"
rm -rf .dart_tool build \
       .flutter-plugins .flutter-plugins-dependencies \
       lib/core/localization/generated

# ---- iOS (macOS only) --------------------------------------------------------
if [ -d ios ] && [ "$(uname)" = "Darwin" ]; then
  step "Cleaning iOS (Pods, Podfile.lock, symlinks, DerivedData)"
  rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/Flutter/ephemeral
  rm -rf "$HOME/Library/Developer/Xcode/DerivedData/Runner-"*
fi

# ---- Android -----------------------------------------------------------------
if [ -d android ]; then
  step "Cleaning Android (Gradle build directories)"
  rm -rf android/.gradle android/app/build android/build
fi

step "Fetching Dart packages (also regenerates localizations)"
"${FLUTTER[@]}" pub get

# ---- Code generation (only if the project uses build_runner) -----------------
if grep -qE '^[[:space:]]*build_runner[[:space:]]*:' pubspec.yaml; then
  step "Rebuilding generated code with build_runner"
  "${DART[@]}" run build_runner build --delete-conflicting-outputs
else
  step "No build_runner dependency — skipping code generation"
fi

# ---- iOS pods (after pub get, which writes the plugin list) -------------------
if [ -d ios ] && [ "$(uname)" = "Darwin" ] && command -v pod >/dev/null 2>&1; then
  # The Podfile post-install hook needs the iOS engine artifacts to exist; a
  # manual `pod install` (unlike `flutter build`) doesn't fetch them, so do it
  # here — especially important right after switching Flutter versions.
  step "Preparing iOS engine artifacts (flutter precache)"
  "${FLUTTER[@]}" precache --ios

  step "Reinstalling CocoaPods (with spec repo update)"
  # CocoaPods needs a UTF-8 locale to normalize the project path (which here
  # contains a space); force it so the script works in any shell.
  ( cd ios && LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install --repo-update )
fi

step "Done — clean rebuild complete"
