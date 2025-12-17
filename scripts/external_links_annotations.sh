#!/bin/bash
# Parse external link report and generate GitHub annotations

set -e

# Color codes for different link statuses
EXPIRED_PATTERN="❌ EXPIRED"
ERROR_PATTERN="⚠️  PROBLEMATIC"
OLD_PATTERN="⏰ CACHED FOR"

# Read from stdin or file
report="${1:--}"

# Track counts
expired_count=0
error_count=0
old_count=0

# Function to generate annotation
generate_annotation() {
    local level="$1"
    local url="$2"
    local message="$3"
    
    # Extract domain from URL for filename reference
    local domain=$(echo "$url" | sed 's|https\?://||' | cut -d'/' -f1)
    
    echo "::${level} file=_posts,title=External Link Issue::${message} - ${url}"
}

# Parse the report
if [[ "$report" == "-" ]]; then
    while IFS= read -r line; do
        # Check for expired links
        if [[ $line =~ \[HTTP\ ([0-9]+)\].*([^ ]*\ old)$ ]]; then
            status="${BASH_REMATCH[1]}"
            if [[ "$status" == "0" || "$status" == "999" ]]; then
                url=$(echo "$line" | sed 's/.*\[HTTP.*\] //' | sed 's/ [0-9]* days old.*//')
                generate_annotation "warning" "$url" "External link expired (HTTP $status)"
                ((expired_count++))
            fi
        fi
        
        # Check for error links (404, 410, 3xx)
        if [[ $line =~ \[HTTP\ (404|410|30[0-9])\] ]]; then
            status="${BASH_REMATCH[1]}"
            url=$(echo "$line" | sed 's/.*\[HTTP.*\] //' | sed 's/ [^ ]*$//')
            if [[ "$status" == "404" || "$status" == "410" ]]; then
                generate_annotation "warning" "$url" "External link returns HTTP $status (should be removed)"
            else
                generate_annotation "notice" "$url" "External link redirects (HTTP $status)"
            fi
            ((error_count++))
        fi
        
        # Check for old cached links
        if [[ $line =~ \[HTTP\ 200\].*\ ([0-9]+)\ days$ ]] && [[ "${BASH_REMATCH[1]}" -gt 7 ]]; then
            days="${BASH_REMATCH[1]}"
            url=$(echo "$line" | sed 's/.*\[HTTP.*\] //' | sed 's/ [0-9]* days.*//')
            generate_annotation "notice" "$url" "External link not rechecked for $days days"
            ((old_count++))
        fi
    done
else
    while IFS= read -r line; do
        # Same logic as above
        if [[ $line =~ \[HTTP\ ([0-9]+)\] ]]; then
            status="${BASH_REMATCH[1]}"
            if [[ "$status" == "0" || "$status" == "999" ]]; then
                url=$(echo "$line" | sed 's/.*\[HTTP.*\] //' | sed 's/ [0-9]* days old.*//')
                generate_annotation "warning" "$url" "External link expired (HTTP $status)"
                ((expired_count++))
            fi
        fi
    done < "$report"
fi

# Generate summary annotation
total=$((expired_count + error_count + old_count))
if [[ $total -gt 0 ]]; then
    echo "::notice title=External Link Report::Found $total problematic external links: $expired_count expired, $error_count errors, $old_count old"
fi
