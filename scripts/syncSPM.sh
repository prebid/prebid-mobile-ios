#!/usr/bin/env bash
set -euo pipefail

# Copies the package sources from a PrebidMobile checkout into a checkout of
# one of the SPM repos (prebid-mobile-ios-sdk or prebid-mobile-ios-adapters).

PACKAGE="${1:-}"
SOURCE="${2:-}"
TARGET="${3:-}"

if [[ -z "$PACKAGE" || -z "$SOURCE" || -z "$TARGET" ]]; then
  echo "🔴 Missing required arguments."
  echo "Usage: $0 <core|adapters> <source_dir> <target_dir>"
  exit 1
fi

case "$PACKAGE" in
  core)
    rsync -a --delete "$SOURCE/Frameworks/"  "$TARGET/Frameworks/"
    rsync -a --delete "$SOURCE/PrebidMobile/" "$TARGET/PrebidMobile/"

    rm -f "$TARGET/PrebidMobile/Package.swift"
    rm -f "$TARGET/PrebidMobile/README-SPM.md"

    cp -f "$SOURCE/PrebidMobile/Package.swift" "$TARGET/Package.swift"
    cp -f "$SOURCE/LICENSE" "$TARGET/LICENSE"
    cp -f "$SOURCE/PrebidMobile/README-SPM.md" "$TARGET/README.md"
    ;;
  adapters)
    rsync -a --delete "$SOURCE/EventHandlers/PrebidMobileAdMobAdapters/" "$TARGET/PrebidMobileAdMobAdapters/"
    rsync -a --delete "$SOURCE/EventHandlers/PrebidMobileMAXAdapters/"   "$TARGET/PrebidMobileMAXAdapters/"
    rsync -a --delete "$SOURCE/EventHandlers/PrebidMobileGAMEventHandlers/" "$TARGET/PrebidMobileGAMEventHandlers/"

    cp -f "$SOURCE/EventHandlers/Package.swift" "$TARGET/Package.swift"
    cp -f "$SOURCE/LICENSE" "$TARGET/LICENSE"
    cp -f "$SOURCE/EventHandlers/README-SPM.md" "$TARGET/README.md"
    ;;
  *)
    echo "🔴 Unknown package '$PACKAGE'. Expected 'core' or 'adapters'."
    exit 1
    ;;
esac
