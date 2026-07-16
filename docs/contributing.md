# Contributing

## Branch Model

The project uses a **main/develop/feature** branching strategy:

| Branch | Purpose |
|--------|---------|
| `main` | Stable releases, protected |
| `develop` | Integration branch for next release |
| `feature/*` | Individual feature work |
| `fix/*` | Bug fixes |
| `docs/*` | Documentation changes |

### Workflow

1. Create a feature branch from `develop`:
   ```bash
   git checkout develop
   git checkout -b feature/my-new-feature
   ```

2. Make your changes with conventional commits (see below)

3. Push and open a PR against `develop`:
   ```bash
   git push origin feature/my-new-feature
   ```

4. After review and CI passes, merge into `develop`

5. `develop` merges into `main` for releases

## Conventional Commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting (no code change) |
| `refactor` | Code restructuring (no feature/fix) |
| `test` | Adding or updating tests |
| `chore` | Build, CI, tooling changes |

### Examples

```bash
feat(security): add nuclei integration to hacker profile
fix(state): handle corrupt checkpoint JSON gracefully
docs(phases): add phase 9 documentation
test(common): add assertion helper tests
chore(ci): update GitHub Actions workflow
```

## Code Style

### Bash

- Use `[[ ]]` instead of `[ ]` for conditionals
- Quote all variables: `"${VAR}"` not `$VAR`
- Use `local` for function-scoped variables
- Prefer `printf` over `echo` for portability
- Use `set -euo pipefail` at the top of scripts
- Functions: `snake_case`, descriptive names

### Library Modules

- Each `lib/*.sh` must be sourceable independently
- Include a header comment describing the module's purpose
- Use the `SCRIPT_DIR` pattern for relative sourcing:
  ```bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "${SCRIPT_DIR}/common.sh"
  ```

### Tests

- One test file per module or feature
- Use assertion helpers from `tests/lib/test-helpers.sh`
- Name test functions `test_<module>_<behavior>()`
- Each test file must be executable standalone

## Adding a New Feature

### 1. Create the library module

```bash
# Create lib/my-feature.sh
cat > lib/my-feature.sh << 'EOF'
#!/usr/bin/env bash
# =============================================================================
# lib/my-feature.sh — Description
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

my_feature_function() {
    # Implementation
}
EOF
```

### 2. Add tests

```bash
# Create tests/test-my-feature.sh
cat > tests/test-my-feature.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

source "${LIB_DIR}/common.sh"
source "${SCRIPT_DIR}/lib/test-helpers.sh"

test_my_feature_basic() {
    local result
    result=$(my_feature_function "input")
    assert_eq "expected" "${result}" "basic functionality works"
}

main() {
    test_my_feature_basic
}

main
EOF
chmod +x tests/test-my-feature.sh
```

### 3. Integrate into main script

```bash
# In setup_i3_kali.sh, source the module
source "${LIB_DIR}/my-feature.sh"

# Call it from a phase function
step_my_feature() {
    header "My Feature"
    my_feature_function
    ok "My feature configured"
}
```

### 4. Update documentation

- Add the module to `docs/architecture.md`
- Document any new flags in `docs/configuration.md`
- Update `CHANGELOG.md` under `[Unreleased]`

## Running Tests Before Submitting

```bash
# Run the full test suite
bash tests/run-tests.sh

# Run specific tests
bash tests/test-common.sh
bash tests/test-my-feature.sh
```

## Reporting Issues

Open an issue on GitHub with:

- **Description:** What happened vs. what you expected
- **Steps to reproduce:** Exact commands you ran
- **Environment:** Kali version, bash version, VM/bare metal
- **Logs:** Relevant output (use `2>&1 | tee setup.log`)

## Release Process

1. Update `CHANGELOG.md` with all changes since last release
2. Merge `develop` into `main`
3. Tag the release:
   ```bash
   git tag -a v2.1.0 -m "Release v2.1.0"
   git push origin v2.1.0
   ```
4. GitHub Actions builds and publishes the release

## License

MIT License. See [LICENSE](https://github.com/statick/kali-i3/blob/main/LICENSE) for details.
