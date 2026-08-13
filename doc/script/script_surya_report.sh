#!/bin/bash
# Generate a Surya markdown report for every Solidity file under src/.
# Output: docOut/surya_report/
set -euo pipefail

cd '../../'
DIR=$(pwd)
DIR_OUT=${DIR}/docOut/surya_report
if ! [ -d "$DIR_OUT" ]; then
    mkdir -p "$DIR_OUT"
fi
cd './src'
DIR=$(pwd)
# -print0 / read -d '' so paths containing whitespace are handled correctly
find "$DIR" -type f -name '*.sol' -print0 | while IFS= read -r -d '' i;
do
    filename=${i##*/}
    npx surya mdreport "${DIR_OUT}/surya_report_${filename}.md" "$i";
done;
