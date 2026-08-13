#!/bin/bash
# Generate a Surya call graph (PNG) for every Solidity file under src/.
# Output: docOut/surya_graph/
set -euo pipefail

cd '../../'
DIR=$(pwd)
DIR_OUT=${DIR}/docOut/surya_graph
if ! [ -d "$DIR_OUT" ]; then
    mkdir -p "$DIR_OUT"
fi
cd './src'
# -print0 / read -d '' so paths containing whitespace are handled correctly
find . -type f -name '*.sol' -print0 | while IFS= read -r -d '' i;
do
    filename=${i##*/}
    npx surya graph "$i" | dot -Tpng > "${DIR_OUT}/surya_graph_${filename}.png";
done;
