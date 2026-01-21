#!/usr/bin/env bash
set -euo pipefail

find _site -name '*.html' -print0 | \
  xargs -0 -n1 bash -c '
    echo "Validating: $0"
    pnpm dlx structured-data-testing-tool -i --file "$0" || exit 1
'