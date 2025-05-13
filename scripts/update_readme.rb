#!/usr/bin/env ruby

require "yaml"
require "date"

posts_dir = "_posts"
readme_path = "README.md"
config_path = "_config.yml"
max_posts = 10

readme_content = File.read(readme_path)

site_config = {}
begin
  site_config = YAML.safe_load(File.read(config_path))
rescue StandardError => e
  puts "Warning: Could not read _config.yml: #{e.message}"
end

site_url = site_config["url"] || ""
puts "Using site URL: #{site_url}"

def parse_front_matter(file_path)
  content = File.read(file_path)
  if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
    yaml_content = Regexp.last_match(1)
    front_matter = YAML.safe_load(yaml_content, permitted_classes: [Date, Time])
    return front_matter
  end
  {}
end

def normalize_date(date_obj)
  return nil unless date_obj

  case date_obj
  when Date
    date_obj.to_time
  when Time
    date_obj
  when String
    begin
      Date.parse(date_obj).to_time
    rescue StandardError
      nil
    end
  end
end

def date_from_filename(filename)
  return unless filename =~ /(\d{4}-\d{2}-\d{2})/

  begin
    Date.parse(Regexp.last_match(1)).to_time
  rescue StandardError
    nil
  end
end

# Extract date parts from filename (YYYY-MM-DD-title.md)
def format_jekyll_url(filename, site_url, permalink_format = nil)
  base = File.basename(filename, ".*")
  
  # Default formatting if no custom permalink structure is provided
  if base =~ /^(\d{4})-(\d{2})-(\d{2})-(.*)/
    year, month, day, slug = $1, $2, $3, $4
    
    # Check for custom permalink format in config or use Jekyll default
    if permalink_format
      url = permalink_format
        .gsub(':year', year)
        .gsub(':month', month)
        .gsub(':day', day)
        .gsub(':title', slug)
    else
      # Jekyll's default permalink structure
      url = "/#{year}/#{month}/#{day}/#{slug}/"
    end
    
    return "#{site_url}#{url}"
  end
  
  # Fallback for non-standard filenames
  "#{site_url}/blog/#{base}/"
end

# Get permalink format from config or use default
permalink_format = site_config["permalink"]
puts "Using permalink format: #{permalink_format || 'default'}"

posts = Dir.glob("#{posts_dir}/*.{md,markdown}")
           .map do |file|
          begin
            front_matter = parse_front_matter(file)
            date = normalize_date(front_matter["date"]) || date_from_filename(File.basename(file))
            
            # Use permalink from front matter if available, otherwise generate from filename
            permalink = front_matter["permalink"]
            url = permalink ? "#{site_url}#{permalink}" : format_jekyll_url(file, site_url, permalink_format)
            
            {
              title: front_matter["title"] || "Untitled",
              date: date,
              date_str: date ? date.strftime("%Y-%m-%d") : "No date",
              url: url,
              filename: file
            }
          rescue StandardError => e
            puts "Error parsing #{file}: #{e.message}"
            nil
          end
        end
           .compact
           .select { |post| post[:date] }
           .sort_by { |post| post[:date] }
           .reverse
           .first(max_posts)

toc = "## Recent Blog Posts\n\n"
posts.each do |post|
  toc += "- #{post[:date_str]}: [#{post[:title]}](#{post[:url]})\n"
end

sections = [
  { title: "About", url: "#{site_url}/about/" },
  { title: "Blog", url: "#{site_url}/blog/" },
  { title: "Contact", url: "#{site_url}/contact/" }
]

site_toc = "## Website Sections\n\n"
sections.each do |section|
  site_toc += "- [#{section[:title]}](#{section[:url]})\n"
end

toc_marker_start = "<!-- BEGIN TOC -->"
toc_marker_end = "<!-- END TOC -->"

new_content = if readme_content.include?(toc_marker_start) && readme_content.include?(toc_marker_end)
                readme_content.gsub(
                  /#{toc_marker_start}.*#{toc_marker_end}/m,
                  "#{toc_marker_start}\n#{site_toc}\n#{toc}\n#{toc_marker_end}"
                )
              else
                readme_content + "\n\n#{toc_marker_start}\n#{site_toc}\n#{toc}\n#{toc_marker_end}\n"
              end

File.write(readme_path, new_content)
puts "README.md updated with latest blog posts and site sections"
