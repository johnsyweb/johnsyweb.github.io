#!/bin/bash
# Parse Lighthouse CI output and create GitHub annotations

set -euo pipefail

INPUT_PATH="${1:-.lighthouseci/manifest.json}"
THEME="${2:-light}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

  local BP_EMOJI="✅"
  [[ "$bp" -lt 90 ]] && BP_EMOJI="⚠️"
  [[ "$bp" -lt 75 ]] && BP_EMOJI="❌"

  local SEO_EMOJI="✅"
  [[ "$seo" -lt 90 ]] && SEO_EMOJI="⚠️"
  [[ "$seo" -lt 75 ]] && SEO_EMOJI="❌"

  local PWA_EMOJI="✅"
  [[ "$pwa" -lt 90 ]] && PWA_EMOJI="⚠️"
  [[ "$pwa" -lt 50 ]] && PWA_EMOJI="❌"

  local LEVEL="notice"
  [[ "$perf" -lt 90 ]] && LEVEL="warning"
  [[ "$a11y" -lt 100 ]] && LEVEL="warning"
  [[ "$bp" -lt 90 ]] && LEVEL="warning"
  [[ "$seo" -lt 90 ]] && LEVEL="warning"

  # Sanitize URL for GitHub annotations (remove protocol for brevity)
  local display_url="${url#http://}"
  display_url="${display_url#https://}"
  
  local TITLE="Lighthouse ($THEME) • ${display_url:-unknown}"
  local MESSAGE="Perf: $PERF_EMOJI $perf | A11y: $A11Y_EMOJI $a11y | BP: $BP_EMOJI $bp | SEO: $SEO_EMOJI $seo | PWA: $PWA_EMOJI $pwa"

  echo "::$LEVEL title=$TITLE::$MESSAGE"
}

if [[ -f "$MANIFEST" ]]; then
  # Prefer manifest if present
  jq -r '.[] | [.url, ((.summary.performance // 0)*100|floor), ((.summary.accessibility // 0)*100|floor), ((.summary["best-practices"] // 0)*100|floor), ((.summary.seo // 0)*100|floor), ((.summary.pwa // 0)*100|floor)] | join("|")' "$MANIFEST" \
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
    # Extract URL and category scores using dedicated jq file
    if ! line=$(jq -r -f "$SCRIPT_DIR/lighthouse_scores.jq" "$report" 2>/dev/null); then
      skipped=$((skipped+1))
      continue
    fi
    IFS='|' read -r url perf a11y bp seo pwa <<< "$line"
    annotate_line "$url" "$perf" "$a11y" "$bp" "$seo" "$pwa"
  done
  if (( skipped > 0 )); then
    echo "::warning::Skipped $skipped Lighthouse report(s) due to parse errors"
  fi
fi
