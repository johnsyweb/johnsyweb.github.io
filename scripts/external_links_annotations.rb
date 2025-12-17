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

links = report['links'] || {}
summary = report['summary'] || {
  'expired' => (links['expired'] || []).length,
  'error' => (links['error'] || []).length,
  'old' => (links['old'] || []).length
}

def emit_annotation(level, title, message, metadata)
  location = ''
  if metadata.is_a?(Array)
    first = metadata.first
    if first.is_a?(Hash) && first['filename']
      location = " file=#{first['filename']}"
      location += ",line=#{first['line']}" if first['line']
    end
  end
  puts "::#{level}#{location} title=#{title}::#{message}"
end

# Generate annotations for expired links
(links['expired'] || []).each do |link|
  url = link['url']
  status = link['status']
  age = link['age']
  emit_annotation('warning', 'External Link Expired', "HTTP #{status} #{url} (cached #{age} days ago)", link['metadata'])
end

# Generate annotations for error links
(links['error'] || []).each do |link|
  url = link['url']
  status = link['status']
  age = link['age']
  type = link['type'] || 'error'
  
  case type
  when 'missing'
    emit_annotation('error', 'External Link Missing', "HTTP #{status} #{url} - link should be removed (cached #{age} days ago)", link['metadata'])
  when 'redirect'
    emit_annotation('warning', 'External Link Redirects', "HTTP #{status} #{url} - may need updating (cached #{age} days ago)", link['metadata'])
  else
    emit_annotation('warning', 'External Link Error', "HTTP #{status} #{url} (cached #{age} days ago)", link['metadata'])
  end
end

# Generate annotations for old cached links
(links['old'] || []).each do |link|
  url = link['url']
  age = link['age']
  emit_annotation('notice', 'External Link Not Rechecked', "#{url} - not verified for #{age} days", link['metadata'])
end

# Generate summary annotation
expired_count = summary['expired'] || (links['expired'] || []).length
error_count = summary['error'] || (links['error'] || []).length
old_count = summary['old'] || (links['old'] || []).length
total_issues = expired_count + error_count

if total_issues > 0
  puts "::notice title=External Link Report::Found #{expired_count} expired, #{error_count} error, #{old_count} old cached (#{total_issues} total issues)"
else
  puts "::notice title=External Link Report::✓ All external links in good status"
end
