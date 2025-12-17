#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

# Read JSON from stdin
json_input = $stdin.read
lines = json_input.split("\n")

# Find the JSON object (should be the last complete JSON object)
json_str = nil
lines.reverse_each do |line|
  if line.start_with?('{')
    json_str = line
    break
  end
end

unless json_str
  puts "::notice::No external link report found"
  exit 0
end

begin
  report = JSON.parse(json_str)
rescue JSON::ParserError => e
  puts "::error::Failed to parse link report: #{e.message}"
  exit 0
end

summary = report['summary'] || {}
links = report['links'] || {}

# Generate annotations for expired links
(links['expired'] || []).each do |link|
  url = link['url']
  status = link['status']
  age = link['age']
  puts "::warning title=External Link Expired::HTTP #{status} #{url} (cached #{age} days ago)"
end

# Generate annotations for error links
(links['error'] || []).each do |link|
  url = link['url']
  status = link['status']
  age = link['age']
  type = link['type'] || 'error'
  
  case type
  when 'missing'
    puts "::error title=External Link Missing::HTTP #{status} #{url} - link should be removed (cached #{age} days ago)"
  when 'redirect'
    puts "::warning title=External Link Redirects::HTTP #{status} #{url} - may need updating (cached #{age} days ago)"
  else
    puts "::warning title=External Link Error::HTTP #{status} #{url} (cached #{age} days ago)"
  end
end

# Generate annotations for old cached links
(links['old'] || []).each do |link|
  url = link['url']
  age = link['age']
  puts "::notice title=External Link Not Rechecked::#{url} - not verified for #{age} days"
end

# Generate summary annotation
expired_count = (links['expired'] || []).length
error_count = (links['error'] || []).length
old_count = (links['old'] || []).length
total_issues = expired_count + error_count

if total_issues > 0
  puts "::notice title=External Link Report::Found #{expired_count} expired, #{error_count} error, #{old_count} old cached (#{total_issues} total issues)"
else
  puts "::notice title=External Link Report::✓ All external links in good status"
end
