#!/usr/bin/env bash
set -euo pipefail

# Builds the SPM demo against the packages as they would be published from this
# checkout, without pushing anything. It clones the two SPM repos, syncs the
# local sources into the clones, tags them and points git at the clones for the
# duration of the build.
#
# Usage: ./scripts/verifySPM.sh [version]
# The version defaults to the one in PrebidMobile.podspec.
#
# Meant for CI runners. SwiftPM records the local commit of each version in its
# fingerprint store (~/.swiftpm/security/fingerprints) and then refuses that
# version at any other commit on the same machine.

GREEN='\033[0;32m'
NC='\033[0m' # No Color

CORE_URL="https://github.com/prebid/prebid-mobile-ios-sdk.git"
ADAPTERS_URL="https://github.com/prebid/prebid-mobile-ios-adapters.git"
TARGET_BRANCH="main"

VERSION="${1:-$(sed -n 's/^ *s\.version *= *"\(.*\)"/\1/p' PrebidMobile.podspec)}"

if [[ -z "$VERSION" ]]; then
  echo "🔴 Could not determine the version."
  echo "Usage: $0 [version]"
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

CORE="$WORKDIR/core"
ADAPTERS="$WORKDIR/adapters"

echo -e "\n${GREEN}Preparing local copies of the SPM packages for ${VERSION}${NC}\n"

git clone --quiet --branch "$TARGET_BRANCH" "$CORE_URL" "$CORE"
git clone --quiet --branch "$TARGET_BRANCH" "$ADAPTERS_URL" "$ADAPTERS"

./scripts/syncSPM.sh core . "$CORE"
./scripts/syncSPM.sh adapters . "$ADAPTERS"

for repo in "$CORE" "$ADAPTERS"; do
  git -C "$repo" add -A

  if git -C "$repo" diff --cached --quiet; then
    echo "$(basename "$repo"): no changes to commit."
  else
    git -C "$repo" -c user.name="verifySPM" -c user.email="verifySPM@localhost" commit --quiet -m "$VERSION"
  fi

  git -C "$repo" tag -f "$VERSION" > /dev/null
  echo "$(basename "$repo"): ${VERSION} -> $(git -C "$repo" rev-parse HEAD)"
done

# Make git serve both package URLs from the local clones during the build.
export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0="url.file://${CORE}.insteadOf"
export GIT_CONFIG_VALUE_0="$CORE_URL"
export GIT_CONFIG_KEY_1="url.file://${ADAPTERS}.insteadOf"
export GIT_CONFIG_VALUE_1="$ADAPTERS_URL"

# Pins or package checkouts left over from an earlier build would be reused
# instead of the local clones, so resolve from scratch.
RESOLVED="PrebidMobile.xcworkspace/xcshareddata/swiftpm/Package.resolved"
rm -f "$RESOLVED"

./scripts/buildPrebidSPM.sh \
    -clonedSourcePackagesDirPath "$WORKDIR/packages" \
    -disablePackageRepositoryCache

# The build only counts if it used the local commits, not what is already published.
for repo in "$CORE" "$ADAPTERS"; do
  revision="$(git -C "$repo" rev-parse HEAD)"

  if ! grep -q "$revision" "$RESOLVED"; then
    echo "🔴 The demo was not built against the local $(basename "$repo") package (expected revision ${revision})."
    exit 1
  fi
done

echo "✅ The SPM demo builds against the local packages for ${VERSION}"
