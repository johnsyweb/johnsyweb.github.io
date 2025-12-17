#!/usr/bin/env bash
set -euo pipefail

# Parse HTML validation errors and create GitHub annotations
# Input: validation errors from stdin in format:
# "file:/path/to/file.html":line.col-line.col: error: Message

# Count errors and warnings
error_count=0
warning_count=0

while IFS= read -r line; do
  # Skip lines that don't contain error/warning markers
  if [[ ! "$line" =~ (error|warning): ]]; then
    continue
  fi

  # Parse the validation output
  # Format: "file:/site/path/to/file.html":line.col-line.col: error: Message
  if [[ "$line" =~ \"file:/site/([^\"]+)\":([0-9]+)\.([0-9]+)-([0-9]+)\.([0-9]+):[[:space:]]*(error|warning):[[:space:]]*(.+)$ ]]; then
    relative_path="${BASH_REMATCH[1]}"
    start_line="${BASH_REMATCH[2]}"
    # start_col="${BASH_REMATCH[3]}"
    # end_line="${BASH_REMATCH[4]}"
    # end_col="${BASH_REMATCH[5]}"
    severity="${BASH_REMATCH[6]}"
    message="${BASH_REMATCH[7]}"
    
    # Convert /site/ path to _site/ for GitHub annotations
    file_path="_site/${relative_path}"
    
    # Convert to GitHub annotation format
    if [[ "$severity" == "error" ]]; then
      echo "::error file=${file_path},line=${start_line}::${message}"
      ((error_count++))
    else
      echo "::warning file=${file_path},line=${start_line}::${message}"
      ((warning_count++))
    fi
  fi
done

# Summary
if [[ $error_count -gt 0 ]] || [[ $warning_count -gt 0 ]]; then
  echo "::notice::HTML Validation: ${error_count} error(s), ${warning_count} warning(s)"
fi
