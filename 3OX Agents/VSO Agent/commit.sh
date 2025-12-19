#!/usr/bin/env bash
# Quick commit script for VSO.AGENT
# Usage: ./commit.sh [optional message]

set -e

cd "$(dirname "$0")"

# Get Sirius time if available
sirius_time=""
if command -v ruby >/dev/null 2>&1 && [[ -f "/root/!CMD.BRIDGE/sirius.clock.rb" ]]; then
  sirius_time=$(ruby "/root/!CMD.BRIDGE/sirius.clock.rb" 2>/dev/null || echo "")
fi

# Use custom message or default
if [[ -n "$1" ]]; then
  msg="$1"
else
  iso=$(date -u +"%Y-%m-%d %H:%M:%S")
  msg="Update VSO.AGENT ${iso}"
  [[ -n "$sirius_time" ]] && msg+=" ${sirius_time}"
fi

# Stage all changes
git add -A

# Check if there's anything to commit
if git diff --cached --quiet; then
  echo "✓ No changes to commit"
  exit 0
fi

# Commit
git commit -m "$msg"
echo "✓ Committed: $msg"

# Push if remote exists
if git remote get-url origin >/dev/null 2>&1; then
  branch=$(git rev-parse --abbrev-ref HEAD)
  git push -u origin "$branch"
  echo "✓ Pushed to origin/$branch"
else
  echo "⚠ No remote configured. Run:"
  echo "  git remote add origin git@github.com:YOUR_USERNAME/vso-agent.git"
fi

