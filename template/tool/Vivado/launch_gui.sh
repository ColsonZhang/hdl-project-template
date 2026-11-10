#!/usr/bin/env bash
# Source Vivado settings and open the Vivado GUI (for interactive work).
set -euo pipefail

VIVADO_SETTINGS="${VIVADO_SETTINGS:-/tools/Xilinx/Vivado/2022.2/settings64.sh}"
if [ ! -f "$VIVADO_SETTINGS" ]; then
    echo "ERROR: Vivado settings not found: $VIVADO_SETTINGS" >&2
    echo "       set VIVADO_SETTINGS=/path/to/Vivado/<version>/settings64.sh" >&2
    exit 1
fi

# shellcheck disable=SC1090
source "$VIVADO_SETTINGS"

cd "$(dirname "$0")"
vivado &
