#!/usr/bin/env bash
set -euo pipefail

# Configure git user.email from env or prompt
if ! git config user.email >/dev/null 2>&1; then
    if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
        git config user.email "$GIT_USER_EMAIL"
    else
        read -rp "Enter git user.email: " GIT_USER_EMAIL
        git config user.email "$GIT_USER_EMAIL"
    fi
fi

# Configure git user.name from env or prompt
if ! git config user.name >/dev/null 2>&1; then
    if [[ -n "${GIT_USER_NAME:-}" ]]; then
        git config user.name "$GIT_USER_NAME"
    else
        read -rp "Enter git user.name: " GIT_USER_NAME
        git config user.name "$GIT_USER_NAME"
    fi
fi

# Initialize git repository if needed
if [[ ! -d .git ]]; then
    git init
fi

# First commit in main
git checkout -B main
git add -A
git commit -m "chore: initial commit"

# Create develop branch
git branch develop

# Create feature branches from main
git branch feature/setup-script
git branch feature/purge-script

echo "Git initialized successfully with branches: main, develop, feature/setup-script, feature/purge-script"
