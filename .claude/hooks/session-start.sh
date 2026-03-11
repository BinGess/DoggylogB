#!/bin/bash
set -euo pipefail

# Only run in remote Claude Code web sessions
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "Setting up Flutter project dependencies..."

# Locate flutter SDK
FLUTTER_BIN=""
for candidate in \
  "$HOME/flutter/bin/flutter" \
  "/opt/flutter/bin/flutter" \
  "/usr/local/flutter/bin/flutter" \
  "$(which flutter 2>/dev/null || true)"; do
  if [ -x "$candidate" ]; then
    FLUTTER_BIN="$candidate"
    break
  fi
done

if [ -z "$FLUTTER_BIN" ]; then
  echo "WARNING: Flutter SDK not found. Skipping flutter pub get."
  exit 0
fi

echo "Found Flutter at: $FLUTTER_BIN"

# Install pub dependencies (idempotent)
cd "${CLAUDE_PROJECT_DIR:-.}"
"$FLUTTER_BIN" pub get

echo "Flutter dependencies installed successfully."
