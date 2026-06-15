#!/bin/bash
#
# verify-release-config.sh
#
# Build-time guard for the CloudKit-required entitlements and Info.plist values.
# Wired up as an Xcode Run Script Build Phase on the PlainWeights target so it
# runs on every build. Fails the build (with a red error in Xcode) if anything
# is wrong, including the dev/prod aps-environment mismatch that historically
# caused a release rollback.
#
# Do not delete or move this script without updating CLAUDE.md and the Build
# Phase that calls it.
#

set -euo pipefail

ENTITLEMENTS="${SRCROOT}/PlainWeights/PlainWeights.entitlements"
INFOPLIST="${SRCROOT}/PlainWeights/Info.plist"
WIDGET_ENTITLEMENTS="${SRCROOT}/PlainWeightsTimerExtension.entitlements"

fail() {
    # Xcode parses "error: ..." in Build Phase output and surfaces it as a
    # red error in the issue navigator, stopping the build.
    echo "error: $1"
    exit 1
}

warn() {
    echo "warning: $1"
}

read_plist() {
    /usr/libexec/PlistBuddy -c "Print :$2" "$1" 2>/dev/null || echo ""
}

# ===========================================================================
# Main app entitlements — always required
# ===========================================================================

[ -f "$ENTITLEMENTS" ] || fail "Entitlements file not found at $ENTITLEMENTS"

APS_ENV=$(read_plist "$ENTITLEMENTS" "aps-environment")
if [ -z "$APS_ENV" ]; then
    fail "PlainWeights.entitlements is missing 'aps-environment'. CloudKit silent push REQUIRES this. Add the key with value 'development' for dev builds, 'production' for App Store. (This is the mistake that broke CloudKit sync once before — see CLAUDE.md.)"
fi

ICLOUD_CONTAINERS=$(read_plist "$ENTITLEMENTS" "com.apple.developer.icloud-container-identifiers")
echo "$ICLOUD_CONTAINERS" | grep -q "iCloud.com.stevolution.PlainWeights" || \
    fail "PlainWeights.entitlements is missing iCloud container 'iCloud.com.stevolution.PlainWeights'."

ICLOUD_SERVICES=$(read_plist "$ENTITLEMENTS" "com.apple.developer.icloud-services")
echo "$ICLOUD_SERVICES" | grep -q "CloudKit" || \
    fail "PlainWeights.entitlements is missing 'CloudKit' under icloud-services. CloudKit sync will not work."

APP_GROUPS=$(read_plist "$ENTITLEMENTS" "com.apple.security.application-groups")
echo "$APP_GROUPS" | grep -q "group\.com\.stevolution\.PlainWeights" || \
    fail "PlainWeights.entitlements is missing App Group 'group.com.stevolution.PlainWeights'."

# ===========================================================================
# Main app Info.plist — always required
# ===========================================================================

[ -f "$INFOPLIST" ] || fail "Info.plist not found at $INFOPLIST"

BG_MODES=$(read_plist "$INFOPLIST" "UIBackgroundModes")
echo "$BG_MODES" | grep -q "remote-notification" || \
    fail "Info.plist is missing UIBackgroundModes: 'remote-notification'. CloudKit silent push REQUIRES this for background sync. (This is the second part of the mistake that broke CloudKit once before — see CLAUDE.md.)"

LIVE_ACT=$(read_plist "$INFOPLIST" "NSSupportsLiveActivities")
[ "$LIVE_ACT" = "true" ] || \
    fail "Info.plist is missing NSSupportsLiveActivities=true. The rest-timer Live Activity needs this."

# ===========================================================================
# Widget extension entitlements
# ===========================================================================

[ -f "$WIDGET_ENTITLEMENTS" ] || fail "Widget extension entitlements not found at $WIDGET_ENTITLEMENTS"

WIDGET_GROUPS=$(read_plist "$WIDGET_ENTITLEMENTS" "com.apple.security.application-groups")
if echo "$WIDGET_GROUPS" | grep -q "group\.\."; then
    fail "PlainWeightsTimerExtension.entitlements has a double-dot typo in the App Group identifier. Must be 'group.com.stevolution.PlainWeights' (single dot). (We hit this exact bug once already — see CLAUDE.md.)"
fi
echo "$WIDGET_GROUPS" | grep -q "group\.com\.stevolution\.PlainWeights" || \
    fail "PlainWeightsTimerExtension.entitlements App Group must match the main app: 'group.com.stevolution.PlainWeights'."

# ===========================================================================
# Swift code-level CloudKit guard rails
# ===========================================================================
#
# Catches accidental code changes that would silently break iCloud sync.
# These checks are grep-based (so not bulletproof against weird formatting),
# but they catch the obvious mistakes that would otherwise ship and break
# everyone's CloudKit sync without anyone noticing until users complain.

APP_SWIFT="${SRCROOT}/PlainWeights/PlainWeightsApp.swift"
MODELS_DIR="${SRCROOT}/PlainWeights/Models"

[ -f "$APP_SWIFT" ] || fail "PlainWeightsApp.swift not found at $APP_SWIFT"

# 1. ModelContainer must enable CloudKit sync.
if ! grep -q "cloudKitDatabase: *\.automatic" "$APP_SWIFT"; then
    fail "PlainWeightsApp.swift no longer sets 'cloudKitDatabase: .automatic' on its ModelConfiguration. CloudKit sync REQUIRES this. If you've changed it to .none or removed the argument, you've silently turned off iCloud sync for every user."
fi

# 2. Persistence must be on (not in-memory only).
if grep -q "isStoredInMemoryOnly: *true" "$APP_SWIFT"; then
    fail "PlainWeightsApp.swift has 'isStoredInMemoryOnly: true' on its ModelConfiguration. This loses all user data on every app launch and disables CloudKit sync. Must be 'false' for the shipping app."
fi
if ! grep -q "isStoredInMemoryOnly: *false" "$APP_SWIFT"; then
    fail "PlainWeightsApp.swift's ModelConfiguration is missing 'isStoredInMemoryOnly: false'. Be explicit so future readers can't assume in-memory."
fi

# 3. All synced models must be in the Schema.
# (Schema(...) array literal must reference each model class.)
for model in Exercise ExerciseSet ExerciseGroup; do
    if ! grep -q "Schema(\[.*${model}\.self" "$APP_SWIFT"; then
        fail "PlainWeightsApp.swift's Schema literal is missing '${model}.self'. Any model left out of the Schema won't sync to CloudKit, but the app won't warn you."
    fi
done

# 4. @Attribute(.unique) is forbidden by CloudKit. Sync will fail at runtime
#    on any model that has it. Easy to add by accident.
if [ -d "$MODELS_DIR" ]; then
    OFFENDERS=$(grep -rl "@Attribute(\.unique)" "$MODELS_DIR" 2>/dev/null || true)
    if [ -n "$OFFENDERS" ]; then
        fail "Found '@Attribute(.unique)' in: $OFFENDERS. CloudKit explicitly forbids unique attributes. Sync will fail at runtime."
    fi
fi

# 5. .deny delete rules are forbidden by CloudKit. Use .cascade or .nullify.
if [ -d "$MODELS_DIR" ]; then
    OFFENDERS=$(grep -rl "deleteRule: *\.deny" "$MODELS_DIR" 2>/dev/null || true)
    if [ -n "$OFFENDERS" ]; then
        fail "Found 'deleteRule: .deny' in: $OFFENDERS. CloudKit forbids the .deny delete rule. Use .cascade or .nullify."
    fi
fi

# ===========================================================================
# Configuration-specific checks
# ===========================================================================

# These are the checks that would have caught the release-rollback mistake.
# Xcode sets $CONFIGURATION to "Debug" or "Release" depending on the build.
# Archive builds use Release.

if [ "${CONFIGURATION:-}" = "Release" ] && [ "$APS_ENV" = "development" ]; then
    fail "Building Release with aps-environment='development'. This is exactly the mistake that broke a previous release. App Store users would lose CloudKit sync silently. Open PlainWeights/PlainWeights.entitlements and change 'development' to 'production' before archiving. (Remember to change it back to 'development' immediately after the archive completes.)"
fi

if [ "${CONFIGURATION:-}" = "Debug" ] && [ "$APS_ENV" = "production" ]; then
    fail "Building Debug with aps-environment='production'. Your dev provisioning profile can't sign this. You probably forgot to change 'production' back to 'development' in PlainWeights.entitlements after archiving."
fi

echo "✓ Release config verified (CONFIGURATION=${CONFIGURATION:-unknown}, aps-environment=$APS_ENV)"
