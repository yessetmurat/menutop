#!/usr/bin/env bash
# Builds a signed release zip of Menutop, and notarizes it when a notary profile is given.
#
# MENUTOP_VERSION           required, the version to ship, such as 0.1.0
# MENUTOP_RELEASE_IDENTITY  required, a "Developer ID Application" signing identity
# MENUTOP_TEAM_ID           required, the team of that identity
# MENUTOP_NOTARY_PROFILE    optional, a profile saved with `xcrun notarytool store-credentials`
# MENUTOP_NOTARY_KEYCHAIN   optional, the keychain holding that profile, for CI
set -euo pipefail

: "${MENUTOP_VERSION:?set MENUTOP_VERSION, such as 0.1.0}"
: "${MENUTOP_RELEASE_IDENTITY:?set MENUTOP_RELEASE_IDENTITY to a Developer ID Application identity}"
: "${MENUTOP_TEAM_ID:?set MENUTOP_TEAM_ID to the team of that identity}"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build="$root/build"
app="$build/release/Build/Products/Release/Menutop.app"
archive="$build/menutop-$MENUTOP_VERSION.zip"

# Notarization needs the hardened runtime (on in Base.xcconfig) and a secure timestamp.
xcodebuild build \
    -project "$root/Menutop.xcodeproj" \
    -scheme Menutop \
    -configuration Release \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$build/release" \
    MARKETING_VERSION="$MENUTOP_VERSION" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$MENUTOP_RELEASE_IDENTITY" \
    DEVELOPMENT_TEAM="$MENUTOP_TEAM_ID" \
    OTHER_CODE_SIGN_FLAGS=--timestamp

codesign --verify --strict --verbose=1 "$app"

if codesign -d --entitlements - --xml "$app" 2>/dev/null | grep -q get-task-allow; then
    echo "the app carries get-task-allow, which notarization rejects" >&2
    exit 1
fi

rm -f "$archive"
ditto -c -k --keepParent "$app" "$archive"

if [ -z "${MENUTOP_NOTARY_PROFILE:-}" ]; then
    echo "Signed, not notarized: $archive"
    exit 0
fi

keychain_option=()
if [ -n "${MENUTOP_NOTARY_KEYCHAIN:-}" ]; then
    keychain_option=(--keychain "$MENUTOP_NOTARY_KEYCHAIN")
fi

xcrun notarytool submit "$archive" --keychain-profile "$MENUTOP_NOTARY_PROFILE" ${keychain_option[@]+"${keychain_option[@]}"} --wait
xcrun stapler staple "$app"

# Zip again, so the archive holds the stapled ticket.
rm -f "$archive"
ditto -c -k --keepParent "$app" "$archive"
spctl --assess --type execute --verbose=2 "$app"
echo "Notarized: $archive"
