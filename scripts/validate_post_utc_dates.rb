#!/usr/bin/env ruby
# frozen_string_literal: true

# Ensure blog post front-matter timestamps are explicit UTC (+0000).
# Usage:
#   ruby scripts/validate_post_utc_dates.rb path/to/post.markdown ...
#   ruby scripts/validate_post_utc_dates.rb --self-test
# With no paths, exits 0 (nothing to check). Pre-commit passes staged _posts files.

FRONT_MATTER_REGEX = /\A---\s*\n(.*?)\n---\s*\n/m
UTC_OFFSET_REGEX = / \+0000\z/

def extract_front_matter_lines(path)
  raw = File.read(path)
  match = FRONT_MATTER_REGEX.match(raw)
  raise "#{path}: missing YAML front matter" unless match

  match[1].lines
end

def timestamp_value(line)
  return unless (match = line.match(/\A(date|updated_at):\s*(.+?)\s*\z/))

  key = match[1]
  value = match[2].delete_prefix("'").delete_prefix('"').delete_suffix("'").delete_suffix('"')
  return if value.empty? || value == "null" || value.start_with?("YYYY-")

  [key, value]
end

def validate_file(path)
  errors = []
  extract_front_matter_lines(path).each do |line|
    key_value = timestamp_value(line)
    next unless key_value

    key, value = key_value
    next if UTC_OFFSET_REGEX.match?(value)

    errors << "#{path}: #{key} must use an explicit UTC offset (+0000), got #{value.inspect}"
  end
  errors
end

def self_test!
  require "tmpdir"

  Dir.mktmpdir("utc-date-test") do |dir|
    good = File.join(dir, "good.markdown")
    File.write(good, <<~POST)
      ---
      layout: post
      title: Good
      date: '2026-11-14 09:45:00 +0000'
      updated_at:
      ---

      Body
    POST

    bad = File.join(dir, "bad.markdown")
    File.write(bad, <<~POST)
      ---
      layout: post
      title: Bad
      date: '2026-11-14 20:45:00'
      ---

      Body
    POST

    raise "expected good post to pass" unless validate_file(good).empty?

    bad_errors = validate_file(bad)
    raise "expected bad post to fail" if bad_errors.empty?
    raise "unexpected error: #{bad_errors}" unless bad_errors.any? { |e| e.include?("+0000") }
  end

  puts "self-test OK"
end

if ARGV == ["--self-test"]
  self_test!
  exit 0
end

paths = ARGV
exit 0 if paths.empty?

missing = paths.reject { |path| File.file?(path) }
if missing.any?
  warn missing.map { |path| "#{path}: file not found" }.join("\n")
  exit 1
end

errors = paths.flat_map { |path| validate_file(path) }
if errors.any?
  warn errors.join("\n")
  warn "\nUse UTC timestamps, e.g. date: '2026-11-14 09:45:00 +0000'"
  warn "Generate with: date -u '+%Y-%m-%d %H:%M:%S +0000'"
  exit 1
end

puts "UTC post dates OK (#{paths.size} file#{'s' unless paths.size == 1})"
