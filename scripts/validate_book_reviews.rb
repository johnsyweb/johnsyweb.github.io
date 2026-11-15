#!/usr/bin/env ruby
# frozen_string_literal: true

# Validate book-review front matter: isbn13 (required) and optional isbn_audio.
# Usage:
#   ruby scripts/validate_book_reviews.rb path/to/post.markdown ...
#   ruby scripts/validate_book_reviews.rb --self-test
# With no paths, exits 0. Pre-commit passes staged _posts files; non-reviews are skipped.

require "yaml"

FRONT_MATTER_REGEX = /\A---\s*\n(.*?)\n---\s*\n/m

def normalize_isbn(value)
  value.to_s.gsub(/[\s-]/, "")
end

def isbn13_checksum_valid?(digits)
  return false unless digits.match?(/\A97[89]\d{10}\z/)

  sum = digits[0, 12].chars.each_with_index.sum do |char, index|
    char.to_i * (index.odd? ? 3 : 1)
  end
  check = (10 - (sum % 10)) % 10
  check == digits[12].to_i
end

def parse_front_matter(path)
  raw = File.read(path)
  match = FRONT_MATTER_REGEX.match(raw)
  raise "#{path}: missing YAML front matter" unless match

  YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
end

def book_review?(front_matter)
  layout = front_matter["layout"].to_s
  categories = Array(front_matter["categories"]).map(&:to_s)
  layout == "review" || categories.include?("books")
end

def validate_isbn_field(path, key, value, required:)
  errors = []
  raw = value

  if raw.nil? || raw.to_s.strip.empty?
    errors << "#{path}: #{key} is required for book reviews" if required
    return errors
  end

  digits = normalize_isbn(raw)
  unless digits.match?(/\A\d{13}\z/)
    errors << "#{path}: #{key} must be a 13-digit ISBN-13 (got #{raw.inspect})"
    return errors
  end

  unless digits.start_with?("978", "979")
    errors << "#{path}: #{key} must start with 978 or 979 (got #{digits})"
  end

  unless isbn13_checksum_valid?(digits)
    errors << "#{path}: #{key} failed ISBN-13 checksum (got #{digits})"
  end

  errors
end

def blank?(value)
  value.nil? || value.to_s.strip.empty?
end

def validate_file(path)
  front_matter = parse_front_matter(path)
  return [] unless book_review?(front_matter)

  errors = []
  errors.concat(validate_isbn_field(path, "isbn13", front_matter["isbn13"], required: true))
  errors.concat(validate_isbn_field(path, "isbn_audio", front_matter["isbn_audio"], required: false))

  if blank?(front_matter["book_title"])
    errors << "#{path}: book_title is required (used to derive the page title)"
  end
  if blank?(front_matter["book_author"])
    errors << "#{path}: book_author is required (used to derive the page title)"
  end

  if front_matter.key?("isbn")
    errors << "#{path}: use isbn13 instead of isbn"
  end

  errors
end

def self_test!
  require "tmpdir"

  Dir.mktmpdir("isbn-test") do |dir|
    good = File.join(dir, "good.markdown")
    File.write(good, <<~POST)
      ---
      layout: review
      categories: [books]
      book_title: Theo of Golden
      book_author: Allen Levi
      isbn13: '9781668236512'
      isbn_audio: '9781668173107'
      date: '2026-11-15 00:00:00 +0000'
      ---

      Body
    POST

    bad_checksum = File.join(dir, "bad-checksum.markdown")
    File.write(bad_checksum, <<~POST)
      ---
      layout: review
      categories: [books]
      book_title: Bad
      book_author: Author
      isbn13: '9781668236513'
      date: '2026-11-15 00:00:00 +0000'
      ---

      Body
    POST

    missing_book = File.join(dir, "missing-book.markdown")
    File.write(missing_book, <<~POST)
      ---
      layout: review
      categories: [books]
      isbn13: '9781668236512'
      date: '2026-11-15 00:00:00 +0000'
      ---

      Body
    POST

    skipped = File.join(dir, "skipped.markdown")
    File.write(skipped, <<~POST)
      ---
      layout: post
      categories: [music]
      title: Not a review
      date: '2026-11-15 00:00:00 +0000'
      ---

      Body
    POST

    raise "expected good review to pass" unless validate_file(good).empty?
    raise "expected bad checksum to fail" if validate_file(bad_checksum).empty?
    raise "expected missing book fields to fail" if validate_file(missing_book).empty?
    raise "expected non-review to be skipped" unless validate_file(skipped).empty?
    raise "checksum helper broken" unless isbn13_checksum_valid?("9781668236512")
    raise "checksum helper false positive" if isbn13_checksum_valid?("9781668236513")
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
  warn "\nisbn13 must be a valid ISBN-13 (13 digits, 978/979, correct check digit)."
  warn "Optional isbn_audio uses the same rules for Libro.fm."
  exit 1
end

puts "Book review ISBNs OK (#{paths.size} file#{'s' unless paths.size == 1})"
