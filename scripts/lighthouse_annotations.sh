#!/bin/bash
# Parse Lighthouse CI manifest JSON output and create GitHub annotations

set -euo pipefail

MANIFEST_FILE="${1:-.lighthouse/manifest.json}"
THEME="${2:-light}"

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "::warning::Manifest file not found: $MANIFEST_FILE"
  exit 0
fi

# Parse each result and create annotations
jq -r '.[] |
  "URL: \(.url) | " +
  "Performance: \(.summary.performance * 100 | floor) | " +
  "Accessibility: \(.summary.accessibility * 100 | floor) | " +
  "Best Practices: \(.summary["best-practices"] * 100 | floor) | " +
  "SEO: \(.summary.seo * 100 | floor) | " +
  "PWA: \(.summary.pwa * 100 | floor)"' "$MANIFEST_FILE" 2>/dev/null | while read -r line; do
  
  URL=$(echo "$line" | sed 's/URL: //;s/ |.*//')
  PERF=$(echo "$line" | grep -oP 'Performance: \K[0-9]+')
  A11Y=$(echo "$line" | grep -oP 'Accessibility: \K[0-9]+')
  BP=$(echo "$line" | grep -oP 'Best Practices: \K[0-9]+')
  SEO=$(echo "$line" | grep -oP 'SEO: \K[0-9]+')
  PWA=$(echo "$line" | grep -oP 'PWA: \K[0-9]+')
  
  # Build emoji indicators
  PERF_EMOJI="✅"
  [[ "$PERF" -lt 90 ]] && PERF_EMOJI="⚠️"
  [[ "$PERF" -lt 75 ]] && PERF_EMOJI="❌"
  
  A11Y_EMOJI="✅"
  [[ "$A11Y" -lt 100 ]] && A11Y_EMOJI="⚠️"
  [[ "$A11Y" -lt 80 ]] && A11Y_EMOJI="❌"
  
  # Determine annotation level
  LEVEL="notice"
  [[ "$PERF" -lt 90 ]] && LEVEL="warning"
  [[ "$A11Y" -lt 100 ]] && LEVEL="warning"
  
  # Create GitHub annotation
  TITLE="Lighthouse ($THEME) • $URL"
  MESSAGE="Perf: $PERF_EMOJI $PERF | A11y: $A11Y_EMOJI $A11Y | BP: $BP | SEO: $SEO | PWA: $PWA"
  
  echo "::$LEVEL title=$TITLE::$MESSAGE"
done
