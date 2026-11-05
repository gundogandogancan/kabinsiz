#!/bin/bash
# V37-07 smoke test: builds kabinsiz-mcp and pipes a fixed JSON-RPC session through it over stdio.
# Usage: tools/mcp/smoke.sh   (from anywhere; prints one response per line)
set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
PKG="$REPO/Packages/KabinsizCore"
swift build --package-path "$PKG" --product kabinsiz-mcp >&2
BIN="$(swift build --package-path "$PKG" --show-bin-path)/kabinsiz-mcp"
FIXTURE="$REPO/apps/ios/Kabinsiz/Features/Mirror/Garments/MirrorFixture.jpg"
GARMENT="$REPO/apps/ios/Kabinsiz/Features/Mirror/Garments/jacket-torso-fabric.png"
PERSON="$REPO/Packages/KabinsizCore/Tests/SelfModelTests/Fixtures/person-a.jpg"
{
  echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"1"}}}'
  echo '{"jsonrpc":"2.0","method":"notifications/initialized"}'
  echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
  echo "{\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"tools/call\",\"params\":{\"name\":\"analyze_garment_photo\",\"arguments\":{\"path\":\"$FIXTURE\"}}}"
  echo "{\"jsonrpc\":\"2.0\",\"id\":4,\"method\":\"tools/call\",\"params\":{\"name\":\"analyze_garment_photo\",\"arguments\":{\"path\":\"$GARMENT\"}}}"
  echo "{\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"tools/call\",\"params\":{\"name\":\"read_product_label\",\"arguments\":{\"path\":\"$FIXTURE\"}}}"
  echo '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"body_profile_defaults","arguments":{"form":"FEMININE"}}}'
  echo '{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"analyze_garment_photo","arguments":{"path":"/etc/hosts"}}}'
  echo "{\"jsonrpc\":\"2.0\",\"id\":8,\"method\":\"tools/call\",\"params\":{\"name\":\"analyze_garment_photo\",\"arguments\":{\"path\":\"$REPO/../outside.png\"}}}"
  echo '{"jsonrpc":"2.0","id":9,"method":"tools/call","params":{"name":"no_such_tool","arguments":{}}}'
  echo '{"jsonrpc":"2.0","id":10,"method":"resources/list"}'
  echo '{"jsonrpc":"2.0","id":11,"method":"tools/call","params":{"name":"body_profile_defaults","arguments":{"form":"GUESS_FROM_PHOTO"}}}'
  echo "{\"jsonrpc\":\"2.0\",\"id\":12,\"method\":\"tools/call\",\"params\":{\"name\":\"analyze_person_photo\",\"arguments\":{\"path\":\"$PERSON\",\"userHeightCm\":170}}}"
  echo "{\"jsonrpc\":\"2.0\",\"id\":13,\"method\":\"tools/call\",\"params\":{\"name\":\"measure_flat_garment\",\"arguments\":{\"path\":\"$GARMENT\"}}}"
  echo '{"jsonrpc":"2.0","id":14,"method":"tools/call","params":{"name":"draft_pattern_svg","arguments":{"kind":"top","form":"FEMININE","measurementsCm":{"CHEST":92}}}}'
  echo '{not json'
  echo '{"jsonrpc":"2.0","id":"p","method":"ping"}'
} | "$BIN"
