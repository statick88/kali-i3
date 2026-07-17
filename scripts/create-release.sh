#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    read -rp "Enter version (e.g., v1.0.0): " VERSION
fi

VERSION_NUM="${VERSION#v}"

if [[ -z "$VERSION_NUM" ]]; then
    echo "Error: Invalid version format. Use semantic versioning (e.g., v1.0.0)" >&2
    exit 1
fi

if ! grep -q "\[Unreleased\]" CHANGELOG.md; then
    echo "Error: [Unreleased] section not found in CHANGELOG.md" >&2
    exit 1
fi

TODAY=$(date +%Y-%m-%d)

sed -i "s/\[Unreleased\]/[$VERSION_NUM] - $TODAY/" CHANGELOG.md

echo "[Unreleased]
------" >>CHANGELOG.md

git add CHANGELOG.md
git commit -m "docs: changelog for $VERSION"

git tag -a "$VERSION" -m "Release $VERSION"

echo "Release $VERSION created successfully!"
echo ""
echo "Next steps:"
echo "  git push origin main"
echo "  git push origin $VERSION"
