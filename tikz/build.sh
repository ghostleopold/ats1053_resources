#!/bin/bash
# Compile the payoff-matrix figures and drop PDF + PNG into the repo root,
# alongside all the other ats1053 images.
#
# Usage:  ./build.sh            # build every figure
#         ./build.sh foo bar    # build foo.tex and bar.tex only
set -euo pipefail

cd "$(dirname "$0")"
out=".."
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if [ $# -gt 0 ]; then
  targets=("$@")
else
  targets=()
  for f in *.tex; do
    # *-style.tex and inc-*.tex are fragments, not documents
    case "$f" in
      *-style.tex|inc-*.tex) continue ;;
    esac
    targets+=("${f%.tex}")
  done
fi

for name in "${targets[@]}"; do
  name="${name%.tex}"
  echo "==> $name"
  pdflatex -interaction=batchmode -halt-on-error \
           -output-directory="$tmp" "$name.tex" >/dev/null
  pdftoppm -r 200 -png -singlefile "$tmp/$name.pdf" "$out/$name"
  cp "$tmp/$name.pdf" "$out/$name.pdf"
done

echo "Done. PNG + PDF written to $(cd "$out" && pwd)"
