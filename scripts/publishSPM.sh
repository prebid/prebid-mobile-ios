#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m' # No Color

WORKDIR="${1:-}"
VERSION="${2:-}"
TARGET_BRANCH="${3:-}"

if [[ -z "$WORKDIR" || -z "$VERSION" || -z "$TARGET_BRANCH" ]]; then
  echo "🔴 Missing required arguments."
  echo "Usage: $0 <workdir> <version> <target_branch>"
  exit 1
fi

TAG="${VERSION}"

pushd "$WORKDIR" >/dev/null

git config user.name  "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

git add -A

if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "${VERSION}"
fi

echo -e "\n${GREEN}Pushing branch to origin/${TARGET_BRANCH}${NC}\n"
git push origin "HEAD:${TARGET_BRANCH}"

echo -e "\n${GREEN}Tagging HEAD with '${TAG}' and pushing tag${NC}\n"
git tag -f "$TAG"
git push origin -f "$TAG"

popd >/dev/null
