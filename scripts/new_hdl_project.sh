#!/usr/bin/env bash
# Create a new HDL project from the blank template.
#
# Usage:
#   bash new_hdl_project.sh <target-dir>
#
# Copies everything inside template/ (including dotfiles such as .gitignore)
# into <target-dir>. Refuses to copy into a non-empty directory.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../template"

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
    echo "usage: $0 <target-dir>" >&2
    echo "  e.g. $0 ~/work/my_hdl_project" >&2
    exit 1
fi

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "ERROR: template directory not found: $TEMPLATE_DIR" >&2
    exit 1
fi

if [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null || true)" ]; then
    echo "ERROR: target exists and is not empty: $TARGET" >&2
    exit 1
fi

mkdir -p "$TARGET"
cp -a "$TEMPLATE_DIR"/. "$TARGET"/

cat <<EOF
Created HDL project skeleton at: $TARGET

Next steps:
  1) edit  $TARGET/readme.md
  2) edit  $TARGET/tool/Vivado/scripts/project/config.tcl
     (project_name, part_name, top_module, xdc_file)
  3) edit  $TARGET/tool/Vivado/xdc/timing.xdc  (clock port / period)
  4) optional: cd $TARGET && git init

Verify the toolchain (Linux with VCS + verible):
  cd $TARGET/tool/VCS
  bash ../VeribleFilelist/initial.sh     # first time: download verible
  pip install anytree                    # first time
  make topmodule=template_tb compile     # generates filelist/template_tb.f + out/simv
  make topmodule=template_tb run         # runs the template testbench
EOF
