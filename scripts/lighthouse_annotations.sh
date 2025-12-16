#!/bin/bash
# Parse Lighthouse CI output and create GitHub annotations

set -euo pipefail

INPUT_PATH="${1:-.lighthouseci/manifest.json}"
THEME="${2:-light}"

# Determine directory and manifest
if [[ -d "$INPUT_PATH" ]]; then
  DIR="$INPUT_PATH"
  MANIFEST="$INPUT_PATH/manifest.json"
else
  DIR="$(dirname "$INPUT_PATH")"
  MANIFEST="$INPUT_PATH"
fi

annotate_line() {
  local url="$1" perf="$2" a11y="$3" bp="$4" seo="$5" pwa="$6"

  local PERF_EMOJI="✅"
  [[ "$perf" -lt 90 ]] && PERF_EMOJI="⚠️"
  [[ "$perf" -lt 75 ]] && PERF_EMOJI="❌"

  local A11Y_EMOJI="✅"
  [[ "$a11y" -lt 100 ]] && A11Y_EMOJI="⚠️"
  [[ "$a11y" -lt 80 ]] && A11Y_EMOJI="❌"

  local LEVEL="notice"
  [[ "$perf" -lt 90 ]] && LEVEL="warning"
  [[ "$a11y" -lt 100 ]] && LEVEL="warning"

  local TITLE="Lighthouse ($THEME) • $url"
  local MESSAGE="Perf: $PERF_EMOJI $perf | A11y: $A11Y_EMOJI $a11y | BP: $bp | SEO: $seo | PWA: $pwa"

  echo "::$LEVEL title=$TITLE::$MESSAGE"
}

if [[ -f "$MANIFEST" ]]; then
  # Prefer manifest if present
  jq -r '.[] | "\(.url)|\(.summary.performance*100|floor)|\(.summary.accessibility*100|floor)|\(.summary[\"best-practices\"]*100|floor)|\(.summary.seo*100|floor)|\(.summary.pwa*100|floor)"' "$MANIFEST" \
    | while IFS='|' read -r url perf a11y bp seo pwa; do
        annotate_line "$url" "$perf" "$a11y" "$bp" "$seo" "$pwa"
      done
else
  # Fallback: parse individual Lighthouse JSON reports
  if [[ ! -d "$DIR" ]]; then
    echo "::warning::Lighthouse output directory not found: $DIR"
    exit 0
  fi
  shopt -s nullglob
  reports=("$DIR"/lhr-*.json "$DIR"/*.report.json)
  if (( ${#reports[@]} == 0 )); then
    echo "::warning::No Lighthouse report JSON files found in $DIR"
    exit 0
  fi
  skipped=0
  for report in "${reports[@]}"; do
    # Extract URL and category scores; tolerate missing/null fields
    if ! line=$(jq -r '"\(.finalUrl // .requestedUrl // "unknown")//\((.categories.performance.score // 0)*100|floor)//\((.categories.accessibility.score // 0)*100|floor)//\((.categories[\"best-practices\"].score // 0)*100|floor)//\((.categories.seo.score // 0)*100|floor)//\((.categories.pwa.score // 0)*100|floor)"' "$report" 2>/dev/null); then
      skipped=$((skipped+1))
      continue
    fi
    IFS='//' read -r url perf a11y bp seo pwa <<< "$line"
    annotate_line "$url" "$perf" "$a11y" "$bp" "$seo" "$pwa"
  done
  if (( skipped > 0 )); then
    echo "::warning::Skipped $skipped Lighthouse report(s) due to parse errors"
  fi
fi
