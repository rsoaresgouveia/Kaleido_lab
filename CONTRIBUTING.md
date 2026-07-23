# Contributing to Kaleido Lab

Thanks for your interest in improving **Kaleido Lab**. This document explains
how we commit, branch, open pull requests, report bugs, and test. Following it
keeps the history clean and the project healthy.

---

## Commit convention

Every commit message uses the format:

```
<emoji> <kind>/<subject>
```

- **subject** is imperative, lower-case, no trailing period, ≤ 72 characters.
- **kind** and its **emoji** are fixed — pick from the table below.
- The commit **date** is the real Git author date; never write it into the message.

| Emoji | Kind      | When to use                                        |
|-------|-----------|----------------------------------------------------|
| ✨    | feat      | A new feature or capability                        |
| 🐛    | fix       | A bug fix                                          |
| 📝    | docs      | Documentation only                                 |
| 🎨    | style     | Formatting / whitespace, no logic change           |
| ♻️    | refactor  | Neither fixes a bug nor adds a feature             |
| ⚡    | perf      | Performance improvement                            |
| ✅    | test      | Adding or correcting tests                         |
| 📦    | build     | Build system or packaging                          |
| 👷    | ci        | CI configuration                                   |
| 🔧    | chore     | Tooling, config, housekeeping                      |
| 🔒    | security  | Security-related change                            |
| ⬆️    | deps      | Dependency upgrade                                 |
| 🔖    | release   | Version bump / release commit                      |
| 🔥    | remove    | Removing code or files                             |
| 🚧    | wip       | Work in progress (feature branches only)           |
| 🔀    | merge     | Merge commit                                       |

Examples:

```
✨ feat/add material 3 light and dark themes
🐛 fix/persist language selection across restarts
📝 docs/document the project structure
```

---

## Branching model

We use a GitFlow variant:

```
feature/*  ─▶  develop  ─▶  RC-<version>  ─▶  main (tagged v<semver>)
```

- **`main`** — production; only release-candidate merges land here, each tagged.
- **`develop`** — integration branch; all finished work lands here first.
- **`feature/<name>`** (or `fix/<name>`) — cut from `develop`, one unit of work,
  merged back into `develop` via a `--no-ff` merge (a Pull Request).
- **`RC-<version>`** — release candidate cut from `develop`; stabilization only;
  merged into `main` (tagged) and back-merged into `develop`.

Never commit directly to `main` or `develop`. Always branch, then merge via PR.

---

## Opening a pull request

1. Branch off `develop`: `git checkout develop && git checkout -b feature/my-thing`.
2. Make focused commits following the convention above.
3. **Run the tests locally and make sure they pass** (see [Testing](#testing)).
4. Push and open a PR **targeting `develop`**.
5. Fill in the PR template: what changed, why, how it was tested, linked issue.
6. Ensure CI is green. Address review comments.
7. Merge with `--no-ff` (or "Create a merge commit") to preserve topology.

---

## Reporting a bug

Open an issue using the **Bug report** template and include:

- **Expected behavior** vs **actual behavior**.
- **Steps to reproduce** (minimal and deterministic).
- **Environment**: OS, Flutter/Dart version, device or emulator, project version.
- **Logs / stack traces**, and a minimal reproduction if possible.

Security issues: do **not** open a public issue — see [Security](#security).

---

## Testing

**Tests must pass locally before every commit, and CI must be green before any
merge.** Run:

```bash
flutter analyze
flutter test
```

New features and bug fixes should come with tests covering the change.

---

## Security

If you discover a security vulnerability, please report it privately rather than
opening a public issue. Do not include exploit details in public channels.

---

## Code of conduct

Be respectful and constructive. Assume good intent. We're all here to build
something good.
