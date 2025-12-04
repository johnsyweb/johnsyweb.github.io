#!/usr/bin/env python3
"""Wrapper script for W3C feedvalidator"""
import sys
import os

# Add feedvalidator to path
feedvalidator_path = os.path.join(os.path.dirname(__file__), '..', 'tmp', 'feedvalidator', 'src')
sys.path.insert(0, feedvalidator_path)

from feedvalidator import validateString

if len(sys.argv) < 2:
    print("Usage: validate_feed.py <feed_file>")
    sys.exit(1)

feed_file = sys.argv[1]

if not os.path.exists(feed_file):
    print(f"Error: Feed file not found: {feed_file}")
    sys.exit(1)

with open(feed_file, 'r', encoding='utf-8') as f:
    feed_content = f.read()

result = validateString(feed_content, firstOccurrenceOnly=0)
events = result.get('loggedEvents', [])

from feedvalidator.logging import Error, Warning
from feedvalidator.formatter.text_plain import Formatter

formatter = Formatter()

errors = [e for e in events if isinstance(e, Error)]
warnings = [e for e in events if isinstance(e, Warning) and not isinstance(e, Error)]

if errors:
    print(f"Validation failed with {len(errors)} error(s):")
    for error in errors:
        print(f"  {formatter.format(error)}")
    sys.exit(1)
elif warnings:
    print(f"Validation passed with {len(warnings)} warning(s):")
    for warning in warnings:
        print(f"  {formatter.format(warning)}")
    sys.exit(0)
else:
    print("Validation passed!")
    sys.exit(0)

