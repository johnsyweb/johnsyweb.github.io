#!/usr/bin/env bash
set -euo pipefail

# Capture side-by-side screenshots comparing a reference (branch/tag/SHA) vs the current branch
# for light and dark modes, and stitch them. Outputs named with today's date and a post slug.
#
# Requirements:
# - bundler (bundle exec jekyll)
# - pnpm (for playwright)
# - ImageMagick (magick/convert) for stitching (optional)
#
# Usage:
#   scripts/capture_accessible_comparisons.sh \
#     --post "accessible-colours-over-solarized" \
#     --compare "origin/main" \
#     --pages "/about/,/blog/"  # optional (defaults to /about/)
#
# Outputs (example for 2025‑12‑16 and post slug):
#   images/2025-12-16-accessible-colours-over-solarized-light.png
#   images/2025-12-16-accessible-colours-over-solarized-dark.png

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BRANCH_SITE="${ROOT_DIR}/tmp/site-branch"
MAIN_WORKTREE="${ROOT_DIR}/tmp/compare-ref"
MAIN_SITE="${ROOT_DIR}/tmp/site-main"
TMP_DIR="${ROOT_DIR}/tmp"
IMAGES_DIR="${ROOT_DIR}/images"
BRANCH_PORT=4100
MAIN_PORT=4101
PIDS=()

# Defaults
DATE_STR="$(date +%Y-%m-%d)"
POST_SLUG="comparison"
COMPARE_REF="origin/main"
PAGES="/about/"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --post)
      POST_SLUG="$2"; shift 2 ;;
    --compare)
      COMPARE_REF="$2"; shift 2 ;;
    --pages)
      PAGES="$2"; shift 2 ;;
    --date)
      DATE_STR="$2"; shift 2 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

cleanup() {
  set +e
  for pid in "${PIDS[@]:-}"; do
    if kill -0 "$pid" 2>/dev/null; then kill "$pid"; fi
  done
  if git -C "$ROOT_DIR" worktree list | grep -q "${MAIN_WORKTREE}"; then
    git -C "$ROOT_DIR" worktree remove --force "$MAIN_WORKTREE" 2>/dev/null || true
  fi
}
trap cleanup EXIT

mkdir -p "$IMAGES_DIR" "$TMP_DIR"

# Build current branch
(cd "$ROOT_DIR" && JEKYLL_ENV=production bundle exec jekyll build --destination "$BRANCH_SITE")

# Checkout comparison ref as a worktree and build it
if git -C "$ROOT_DIR" worktree list | grep -q "${MAIN_WORKTREE}"; then
  git -C "$ROOT_DIR" worktree remove --force "$MAIN_WORKTREE"
fi
git -C "$ROOT_DIR" worktree add "$MAIN_WORKTREE" "$COMPARE_REF"
(cd "$MAIN_WORKTREE" && JEKYLL_ENV=production bundle exec jekyll build --destination "$MAIN_SITE")

# Serve both builds (ruby stdlib httpd keeps stdout simple for readiness checks)
ruby -run -ehttpd "$BRANCH_SITE" -p "$BRANCH_PORT" -b 127.0.0.1 >/dev/null 2>&1 &
PIDS+=("$!")
ruby -run -ehttpd "$MAIN_SITE" -p "$MAIN_PORT" -b 127.0.0.1 >/dev/null 2>&1 &
PIDS+=("$!")

# Wait for servers
for port in "$BRANCH_PORT" "$MAIN_PORT"; do
  for _ in {1..50}; do
    if nc -z 127.0.0.1 "$port" 2>/dev/null; then break; fi
    sleep 0.1
  done
    nc -z 127.0.0.1 "$port" 2>/dev/null || { echo "Port $port not listening" >&2; exit 1; }
  done

# Ensure browser is available (normally handled by pnpm postinstall)
pnpm exec playwright install chromium >/dev/null 2>&1 || true

OUT_PREFIX="${DATE_STR}-${POST_SLUG}"
pnpm exec node scripts/capture.mjs \
  --branch-url "http://127.0.0.1:${BRANCH_PORT}" \
  --main-url "http://127.0.0.1:${MAIN_PORT}" \
  --out-dir "${IMAGES_DIR}" \
  --tmp-dir "${TMP_DIR}" \
  --out-prefix "${OUT_PREFIX}" \
  --pages "${PAGES}"

echo "Done. Check ${IMAGES_DIR}/${OUT_PREFIX}-light.png and ...-dark.png"
