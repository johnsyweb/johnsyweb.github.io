#!/usr/bin/env bash
set -euo pipefail

echo "Building site with Jekyll..."
bundle exec jekyll build

echo "Generating Pagefind index..."
npx --yes pagefind --site _site --output-path assets/pagefind --force-language en

echo "Cleaning build artifacts..."
rm -rf _site

echo "Pagefind index updated in assets/pagefind/"

