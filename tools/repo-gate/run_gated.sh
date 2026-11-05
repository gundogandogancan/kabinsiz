#!/bin/bash
# V37-08 repo gate: look at an external research repository before anything in it runs.
#
#   run_gated.sh --repo <git URL or local path> --workdir <dir> [--ref <branch|tag>] [--i-reviewed] [-- <command> [args...]]
#
# Steps, in order; nothing from the repository is executed before step 5:
#   1. clone into a fresh directory under --workdir (hooks, submodules, LFS smudge and checkout filters off)
#   2. licence detection (LICENSE/COPYING/README → SPDX guess → verdict)
#   3. secret / credential pattern scan (values are masked in the output)
#   4. install scripts and code-executing files listed for human review
#   5. only if a command is given after `--`: run it under sandbox-exec (gate.sb): no network,
#      no writes outside the clone, no reading of credentials; a clean environment (no tokens).
#
# Verdicts: RESEARCH_ONLY_NEVER_SHIP (NC / research-only / SMPL family: may be studied, never shipped),
# BLOCKED (no or unknown licence: nothing runs), PERMISSIVE_REVIEW / COPYLEFT_REVIEW (runs; shipping
# still needs the licence gate in docs/architecture/V35_LICENSE_GATE.md).
# A command runs only with --i-reviewed when step 3 or 4 found something.
set -euo pipefail

die() { echo "repo-gate: $*" >&2; exit 2; }
GATE_DIR="$(cd "$(dirname "$0")" && pwd -P)"
PROFILE="$GATE_DIR/gate.sb"

REPO="" WORKDIR="" REF="" REVIEWED=0
CMD=()
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --workdir) WORKDIR="${2:-}"; shift 2 ;;
    --ref) REF="${2:-}"; shift 2 ;;
    --i-reviewed) REVIEWED=1; shift ;;
    --) shift; CMD=("$@"); break ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) die "unknown argument: $1 (see --help)" ;;
  esac
done
[ -n "$REPO" ] || die "--repo is required"
[ -n "$WORKDIR" ] || die "--workdir is required"
[ -f "$PROFILE" ] || die "sandbox profile missing: $PROFILE"
command -v sandbox-exec >/dev/null || die "sandbox-exec not found (macOS only)"

mkdir -p "$WORKDIR"
WORKDIR="$(cd "$WORKDIR" && pwd -P)"
NAME="$(basename "${REPO%/}" .git | tr -c 'A-Za-z0-9._\n-' '_')"
CLONE="$WORKDIR/$NAME-$(date +%Y%m%d-%H%M%S)-$$"
[ ! -e "$CLONE" ] || die "clone directory already exists: $CLONE"
REPORT="$CLONE.gate-report.txt"
exec > >(tee "$REPORT") 2>&1

echo "== repo-gate $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "repo:    $REPO"
echo "clone:   $CLONE"

# ---- 1. clone (no execution) -------------------------------------------------------------
echo; echo "== 1. clone"
CLONE_ARGS=(--depth 1 --no-recurse-submodules)
[ -n "$REF" ] && CLONE_ARGS+=(--branch "$REF")
GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 GIT_CONFIG_NOSYSTEM=1 \
  git -c core.hooksPath=/dev/null -c core.fsmonitor=false -c core.symlinks=false \
      -c filter.lfs.smudge= -c filter.lfs.process= -c filter.lfs.required=false \
      -c protocol.ext.allow=never \
      clone "${CLONE_ARGS[@]}" -- "$REPO" "$CLONE"
CLONE="$(cd "$CLONE" && pwd -P)"
echo "commit:  $(git -C "$CLONE" rev-parse HEAD)"
echo "files:   $(find "$CLONE" -path "$CLONE/.git" -prune -o -type f -print | wc -l | tr -d ' ')"

# ---- 2. licence -----------------------------------------------------------------------------
echo; echo "== 2. licence"
LICENCE_FILES=()
while IFS= read -r f; do LICENCE_FILES+=("$f"); done < <(find "$CLONE" -maxdepth 1 -type f \
  \( -iname 'LICENSE*' -o -iname 'LICENCE*' -o -iname 'COPYING*' -o -iname 'NOTICE*' \) | sort)
SPDX="NONE"
if [ ${#LICENCE_FILES[@]} -gt 0 ]; then
  TEXT="$(cat "${LICENCE_FILES[@]}")"
  has() { printf '%s' "$TEXT" | grep -qiE "$1"; }
  if   has 'GNU AFFERO GENERAL PUBLIC LICENSE'; then SPDX="AGPL-3.0"
  elif has 'GNU LESSER GENERAL PUBLIC LICENSE'; then SPDX="LGPL"
  elif has 'GNU GENERAL PUBLIC LICENSE' && has 'Version 3'; then SPDX="GPL-3.0"
  elif has 'GNU GENERAL PUBLIC LICENSE'; then SPDX="GPL-2.0"
  elif has 'Mozilla Public License' && has '2\.0'; then SPDX="MPL-2.0"
  elif has 'Apache License' && has 'Version 2\.0'; then SPDX="Apache-2.0"
  elif has 'Permission is hereby granted, free of charge'; then SPDX="MIT"
  elif has 'Redistribution and use in source and binary forms' && has 'Neither the name'; then SPDX="BSD-3-Clause"
  elif has 'Redistribution and use in source and binary forms'; then SPDX="BSD-2-Clause"
  elif has 'Permission to use, copy, modify, and/or distribute this software'; then SPDX="ISC"
  elif has 'This is free and unencumbered software released into the public domain'; then SPDX="Unlicense"
  elif has 'CC0 1\.0'; then SPDX="CC0-1.0"
  else SPDX="UNKNOWN"
  fi
  printf 'file:    %s\n' "${LICENCE_FILES[@]#$CLONE/}"
fi
echo "spdx:    $SPDX (guess from text, not a legal opinion)"

# Research-only signals win over any SPDX guess: the licence, the README or a model-card can narrow it.
NC_PATTERN='non[- ]?commercial|NonCommercial|CC[- ]BY[- ]NC|research (purposes )?only|academic (use )?only|not for commercial|Source Code License-NC|\bSMPL(-X|-H|\+H)?\b|smplx|Max Planck|MANO model|FLAME model'
NC_HITS="$(find "$CLONE" -maxdepth 2 -type f \( -iname 'LICENSE*' -o -iname 'LICENCE*' -o -iname 'COPYING*' -o -iname 'README*' \
  -o -iname 'MODEL_CARD*' -o -iname 'requirements*.txt' -o -iname 'setup.py' -o -iname 'pyproject.toml' -o -iname 'environment*.yml' \) \
  -exec grep -HinoE "$NC_PATTERN" {} + 2>/dev/null | sed "s|^$CLONE/||" | sort -u | head -20 || true)"
if [ -n "$NC_HITS" ]; then
  VERDICT="RESEARCH_ONLY_NEVER_SHIP"
  echo "research-only signals:"; printf '%s\n' "$NC_HITS" | sed 's/^/  /'
else
  case "$SPDX" in
    MIT|Apache-2.0|BSD-2-Clause|BSD-3-Clause|ISC|Unlicense|CC0-1.0) VERDICT="PERMISSIVE_REVIEW" ;;
    GPL-2.0|GPL-3.0|AGPL-3.0|LGPL|MPL-2.0) VERDICT="COPYLEFT_REVIEW" ;;
    *) VERDICT="BLOCKED" ;;
  esac
fi
echo "verdict: $VERDICT"

# ---- 3. secrets -----------------------------------------------------------------------------
echo; echo "== 3. secret / credential scan"
SECRET_PATTERN='AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|-----BEGIN ([A-Z]+ )?PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}|xox[abprs]-[A-Za-z0-9-]{10,}|sk-ant-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{32,}|AIza[0-9A-Za-z_-]{35}|hf_[A-Za-z0-9]{30,}|glpat-[A-Za-z0-9_-]{20}|(api[_-]?key|secret|token|passw(or)?d)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"'[:space:]]{12,}["'"'"']'
SECRETS="$(grep -rIEno --exclude-dir=.git "$SECRET_PATTERN" "$CLONE" 2>/dev/null \
  | sed "s|^$CLONE/||" \
  | awk -F: '{ v=$3; for (i=4;i<=NF;i++) v=v":"$i; m=substr(v,1,6); printf "%s:%s: %s… (%d chars, masked)\n", $1, $2, m, length(v) }' \
  | head -50 || true)"
SECRET_COUNT=0
if [ -n "$SECRETS" ]; then SECRET_COUNT="$(printf '%s\n' "$SECRETS" | wc -l | tr -d ' ')"; printf '%s\n' "$SECRETS"; fi
echo "findings: $SECRET_COUNT"

# ---- 4. install scripts and code-executing files ---------------------------------------------
echo; echo "== 4. install scripts and code-executing files (read these before running anything)"
INSTALL="$(cd "$CLONE" && find . -path ./.git -prune -o -type f \( \
    -name setup.py -o -name setup.cfg -o -name pyproject.toml -o -name 'requirements*.txt' -o -name 'environment*.yml' \
    -o -name Makefile -o -name GNUmakefile -o -name CMakeLists.txt -o -name configure -o -name build.rs -o -name Cargo.toml \
    -o -name Gemfile -o -name Podfile -o -name Package.swift -o -name Dockerfile -o -name 'install*.sh' -o -name 'build*.sh' \
    -o -name 'download*.sh' -o -name hubconf.py -o -name .gitmodules -o -name .pre-commit-config.yaml -o -name .gitattributes \
  \) -print | sed 's|^\./||' | sort || true)"
NPM_HOOKS="$(cd "$CLONE" && find . -path ./.git -prune -o -name package.json -type f -print \
  | xargs grep -lE '"(preinstall|install|postinstall|prepare|prepublish)"[[:space:]]*:' 2>/dev/null | sed 's|^\./||' || true)"
PICKLES="$(cd "$CLONE" && find . -path ./.git -prune -o -type f \( -name '*.pkl' -o -name '*.pickle' -o -name '*.pt' -o -name '*.pth' \
  -o -name '*.ckpt' -o -name '*.bin' -o -name '*.joblib' -o -name '*.npy' \) -print | sed 's|^\./||' | sort || true)"
EXEC_BITS="$(cd "$CLONE" && find . -path ./.git -prune -o -type f -perm -u+x -print | sed 's|^\./||' | sort | head -30 || true)"
INSTALL_COUNT=0
show() { [ -n "$2" ] && { echo "$1:"; printf '  %s\n' $2; INSTALL_COUNT=$((INSTALL_COUNT + $(printf '%s\n' "$2" | wc -l))); } || true; }
IFS=$'\n'
show "build/install files" "$INSTALL"
show "package.json with lifecycle scripts" "$NPM_HOOKS"
show "pickle-style weights (loading them executes code)" "$PICKLES"
show "executable files" "$EXEC_BITS"
unset IFS
echo "findings: $INSTALL_COUNT"

# ---- 5. sandboxed run ---------------------------------------------------------------------------
echo; echo "== 5. run"
if [ ${#CMD[@]} -eq 0 ]; then
  echo "no command given: nothing was executed. Report: $REPORT"
  exit 0
fi
if [ "$VERDICT" = "BLOCKED" ]; then
  echo "refused: licence is $SPDX → BLOCKED. Nothing from this repository runs."
  exit 3
fi
if [ $((SECRET_COUNT + INSTALL_COUNT)) -gt 0 ] && [ "$REVIEWED" -ne 1 ]; then
  echo "refused: steps 3/4 found $SECRET_COUNT secret(s) and $INSTALL_COUNT file(s) to review. Read them, then re-run with --i-reviewed."
  exit 4
fi
[ "$VERDICT" = "RESEARCH_ONLY_NEVER_SHIP" ] && echo "NOTE: RESEARCH_ONLY_NEVER_SHIP — results may inform research notes only; no code, weights or outputs enter the app."
mkdir -p "$CLONE/.gate-home" "$CLONE/.gate-tmp"
USER_HOME="$(cd "$HOME" && pwd -P)"
echo "command: ${CMD[*]}"
echo "sandbox: $PROFILE (network, LaunchServices, launchd, terminal and home folder denied; writes only under the clone, not its .git)"
set +e
( cd "$CLONE" && sandbox-exec -f "$PROFILE" -D CLONE_DIR="$CLONE" -D USER_HOME="$USER_HOME" \
    /usr/bin/env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin HOME="$CLONE/.gate-home" TMPDIR="$CLONE/.gate-tmp/" \
      LANG=en_US.UTF-8 PIP_NO_INDEX=1 PIP_CACHE_DIR="$CLONE/.gate-tmp/pip" HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 \
      "${CMD[@]}" </dev/null 2>&1 | cat )
STATUS=$?   # pipefail (set above) carries the command's status through the pipe
set -e
echo "exit:    $STATUS"
echo "report:  $REPORT"
exit $STATUS
