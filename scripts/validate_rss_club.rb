#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "time"
require "uri"

POST_GLOB = "_posts/*.{md,markdown}"
FRONT_MATTER_REGEX = /\A---\s*\n(.*?)\n---\s*\n/m
COMMON_WORDS = %w[
  the and to of a in is it that for on with as this be are was by at from or an
  if not have has but you we they their can will about more one all
].freeze

def rot13(text)
  text.tr("A-Za-z", "N-ZA-Mn-za-m")
end

def english_score(text)
  downcased = text.to_s.downcase
  COMMON_WORDS.sum do |word|
    downcased.scan(/\b#{Regexp.escape(word)}\b/).size
  end
end

def probably_rot13_encoded?(content)
  encoded_score = english_score(content)
  decoded_score = english_score(rot13(content))
  decoded_score > encoded_score
end

def parse_post(path)
  raw = File.read(path)
  match = FRONT_MATTER_REGEX.match(raw)
  raise "Missing front matter in #{path}" unless match

  front_matter = YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
  body = raw[match[0].length..] || ""
  [front_matter, body]
end

def assert(condition, message)
  raise message unless condition
end

posts = Dir.glob(POST_GLOB).sort.filter_map do |path|
  front_matter, body = parse_post(path)
  categories = Array(front_matter["categories"])
  next unless categories.include?("rss-club")

  {
    path: path,
    title: front_matter["title"].to_s,
    body: body
  }
end

if posts.empty?
  puts "No rss-club posts found; validation skipped."
  exit(0)
end

posts.each do |post|
  assert(probably_rot13_encoded?(post[:body]), "#{post[:path]} is not ROT13 encoded in git storage")
end

sitemap_path = "_site/sitemap.xml"
assert(File.exist?(sitemap_path), "Missing built sitemap at #{sitemap_path}")
sitemap_content = File.read(sitemap_path)

rss_path = "_site/rss.xml"
atom_path = "_site/atom.xml"
assert(File.exist?(rss_path), "Missing built RSS feed")
assert(File.exist?(atom_path), "Missing built Atom feed")
rss_content = File.read(rss_path)
atom_content = File.read(atom_path)

blog_listing_paths = ["_site/blog/index.html"] + Dir.glob("_site/blog/page*/index.html")
blog_pages = blog_listing_paths.filter_map do |path|
  next unless File.exist?(path)

  File.read(path)
end

posts.each do |post|
  title_pattern = Regexp.escape("<title>#{post[:title]}</title>")
  rss_item = rss_content.match(/<item>\s*#{title_pattern}.*?<link>([^<]+)<\/link>/m)
  atom_entry = atom_content.match(/<entry>\s*#{title_pattern}.*?<link href="([^"]+)"/m)
  assert(rss_item, "rss.xml missing rss-club post title #{post[:title]}")
  assert(atom_entry, "atom.xml missing rss-club post title #{post[:title]}")

  post_url = URI(rss_item[1]).path
  atom_url = URI(atom_entry[1]).path
  assert(post_url == atom_url, "RSS and Atom URL mismatch for #{post[:title]}")

  canonical_url = post_url.end_with?("/") ? post_url : "#{post_url}/"
  built_page_path = File.join("_site", canonical_url, "index.html")
  assert(File.exist?(built_page_path), "Missing built page for #{post[:path]} at #{built_page_path}")

  built_page = File.read(built_page_path)
  assert(built_page.match?(/<meta name="robots" content="[^"]*noindex/i), "Expected noindex meta for #{post[:path]}")
  assert(!sitemap_content.include?(canonical_url), "rss-club post appears in sitemap: #{canonical_url}")
  assert(rss_content.include?(canonical_url), "rss.xml missing rss-club post URL #{canonical_url}")
  assert(atom_content.include?(canonical_url), "atom.xml missing rss-club post URL #{canonical_url}")

  blog_pages.each do |blog_page|
    assert(!blog_page.include?(canonical_url), "rss-club post appears on blog listing: #{canonical_url}")
  end
end

puts "rss-club validation passed for #{posts.size} post(s)."
