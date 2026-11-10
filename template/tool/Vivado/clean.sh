#!/usr/bin/env bash
# Remove generated Vivado project/output directories for a clean rebuild.
set -u
cd "$(dirname "$0")"

rm -rf projects output .Xil
rm -f vivado.log vivado.jou
find . -maxdepth 1 -name "*.str" -delete
find . -maxdepth 2 -name "*.jou" -delete
find . -maxdepth 2 -name "*.log" -delete

echo "cleaned: projects/ output/ .Xil/ *.log *.jou *.str"
