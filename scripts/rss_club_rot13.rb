#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

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

def split_post_content(path)
  content = File.read(path)
  match = FRONT_MATTER_REGEX.match(content)
  raise "Missing front matter in #{path}" unless match

  front_matter = YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
  body = content[match[0].length..] || ""
  [front_matter, match[0], body]
end

def rss_club_post?(front_matter)
  Array(front_matter["categories"]).include?("rss-club")
end

def each_rss_club_post
  Dir.glob(POST_GLOB).sort.each do |path|
    front_matter, header, body = split_post_content(path)
    next unless rss_club_post?(front_matter)

    yield(path, header, body)
  end
end

def rewrite_post(path, header, body)
  File.write(path, "#{header}#{body}")
end

command = ARGV.fetch(0, nil)
unless %w[encode decode check].include?(command)
  warn "Usage: ruby scripts/rss_club_rot13.rb [encode|decode|check]"
  exit(1)
end

changed = 0
already = 0
invalid = []

each_rss_club_post do |path, header, body|
  encoded = probably_rot13_encoded?(body)

  case command
  when "encode"
    if encoded
      already += 1
      next
    end
    rewrite_post(path, header, rot13(body))
    changed += 1
  when "decode"
    unless encoded
      already += 1
      next
    end
    rewrite_post(path, header, rot13(body))
    changed += 1
  when "check"
    invalid << path unless encoded
  end
end

case command
when "check"
  if invalid.empty?
    puts "All rss-club posts are ROT13 encoded in git storage."
    exit(0)
  end

  warn "Found non-ROT13 rss-club posts:"
  invalid.each { |path| warn " - #{path}" }
  warn "Run: ruby scripts/rss_club_rot13.rb encode"
  exit(1)
else
  puts "Updated #{changed} rss-club post(s); #{already} already in desired state."
end
