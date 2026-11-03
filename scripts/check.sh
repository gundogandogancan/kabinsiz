#!/bin/zsh
# Local gate: core unit tests, then iOS build + UI acceptance tests on the simulator.
# Usage: scripts/check.sh [simulator name]   (default: iPhone 17)
set -euo pipefail
ROOT=${0:A:h:h}
SIM=${1:-"iPhone 17"}

echo "== KabinsizCore: swift test"
(cd "$ROOT/Packages/KabinsizCore" && swift test)

echo "== iOS: xcodegen + UI tests on $SIM (SIMULATOR_ONLY)"
cd "$ROOT/apps/ios"
"${XCODEGEN:-$HOME/.local/bin/xcodegen}" generate --quiet
# A cold simulator launched by xcodebuild often refuses the test runner ("Busy, failed preflight
# checks"). Boot it first and wait until it has finished booting.
xcrun simctl boot "$SIM" 2>/dev/null || true
xcrun simctl bootstatus "$SIM" -b > /dev/null
xcodebuild -project Kabinsiz.xcodeproj -scheme Kabinsiz \
  -destination "platform=iOS Simulator,name=$SIM" \
  -derivedDataPath build -resultBundlePath "build/uitest-$(date +%Y%m%d-%H%M%S).xcresult" test \
  | grep -E "Test Case .*(passed|failed)|error:|TEST (SUCCEEDED|FAILED)"
