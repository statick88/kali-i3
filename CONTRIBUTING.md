# Contributing Guide

## Quick path

1. Branch from `develop`: `git checkout develop && git checkout -b feature/my-feature`
2. Work and commit with conventional commits
3. Merge to `develop`: `git merge --no-ff feature/my-feature`
4. When ready, merge to `main`: `git merge --no-ff develop && git tag -a vX.Y.Z`

## Branch structure

| Branch | Purpose |
|--------|---------|
| `main` | Stable, production-ready code |
| `develop` | Integration branch for features |
| `feature/*` | Individual feature development |

## Running tests

Before submitting a PR, run the full test suite:

```bash
bash tests/run-tests.sh
```

Syntax check all scripts:

```bash
bash -n lib/*.sh
bash -n setup_i3_kali.sh
bash -n purge_xfce.sh
```

## Conventional commits

Format: `type(scope): description`

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring (no behavior change) |
| `test` | Adding or updating tests |
| `docs` | Documentation changes |
| `chore` | Maintenance tasks |

Examples:

```
feat(setup): add i3-wm core packages
fix(purge): handle missing XDG directories
refactor(lib): extract shared logging functions
test(common): add log level color tests
```

## Project layout

```
lib/          shared bash modules (source from scripts)
tests/        test suite (run: bash tests/run-tests.sh)
docs/         installation guide
```

When adding a new shared function, put it in the appropriate `lib/` module. When adding a new test, add it to the relevant `test-*.sh` file or create a new one following the existing pattern.
