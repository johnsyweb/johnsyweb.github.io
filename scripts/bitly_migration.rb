#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require 'yaml'
require 'date'
require 'uri'
require 'set'

class BitlyMigrator
  INTERNAL_DOMAINS = ['johnsy.com', 'johnsy.net', 'johnsy.org'].freeze
  BITLY_JSON_PATH = '/Users/paj/Downloads/bitly.json'
  
  def initialize
    @workspace_root = File.expand_path('..', __dir__)
    @posts_dir = File.join(@workspace_root, '_posts')
    @links_dir = File.join(@workspace_root, 'l')
    @used_filenames = Set.new
  end
  
  def migrate
    puts "Starting bit.ly migration..."
    
    # Ensure directories exist
    FileUtils.mkdir_p(@links_dir)
    
    # Load and filter bit.ly data
    bitly_data = load_bitly_data
    active_links = bitly_data.select { |link| link['numberOfClicks'] > 0 }
    
    puts "Found #{active_links.length} links with clicks (out of #{bitly_data.length} total)"
    
    active_links.each do |link|
      if internal_link?(link['long_url'])
        process_internal_link(link)
      else
        process_external_link(link)
      end
    end
    
    puts "Migration completed!"
  end
  
  private
  
  def load_bitly_data
    unless File.exist?(BITLY_JSON_PATH)
      raise "bit.ly JSON file not found at #{BITLY_JSON_PATH}"
    end
    
    JSON.parse(File.read(BITLY_JSON_PATH))
  end
  
  def internal_link?(url)
    uri = URI.parse(url)
    INTERNAL_DOMAINS.include?(uri.host)
  rescue URI::InvalidURIError
    false
  end
  
  def process_internal_link(link)
    post_file = find_post_file(link['long_url'])
    
    unless post_file
      puts "Warning: Could not find post file for #{link['long_url']}"
      return
    end
    
    add_redirects_to_post(post_file, link)
    puts "Updated internal link: #{link['backhalf']} -> #{post_file}"
  end
  
  def process_external_link(link)
    filename = generate_external_filename(link)
    filepath = File.join(@links_dir, filename, 'index.md')
    
    FileUtils.mkdir_p(File.dirname(filepath))
    
    content = generate_external_link_content(link)
    File.write(filepath, content)
    
    puts "Created external link: #{link['backhalf']} -> #{filepath}"
  end
  
  def find_post_file(long_url)
    # Extract date and slug from URL like /blog/2025/04/28/shoulder-injury/
    match = long_url.match(%r{/blog/(\d{4})/(\d{2})/(\d{2})/([^/]+)/?$})
    return nil unless match
    
    year, month, day, slug = match.captures
    filename = "#{year}-#{month}-#{day}-#{slug}.markdown"
    filepath = File.join(@posts_dir, filename)
    
    return filepath if File.exist?(filepath)
    
    # Try with .md extension
    alt_filename = "#{year}-#{month}-#{day}-#{slug}.md"
    alt_filepath = File.join(@posts_dir, alt_filename)
    
    return alt_filepath if File.exist?(alt_filepath)
    
    # Create the file if it doesn't exist
    create_post_file(filepath, extract_title_from_url(long_url))
    filepath
  end
  
  def extract_title_from_url(url)
    match = url.match(%r{/([^/]+)/?$})
    return "Untitled Post" unless match
    
    match[1].split('-').map(&:capitalize).join(' ')
  end
  
  def create_post_file(filepath, title)
    date = File.basename(filepath).match(/^(\d{4}-\d{2}-\d{2})/)[1]
    
    content = <<~YAML
      ---
      title: "#{title}"
      date: #{date}
      ---
      
      <!-- This post was created during bit.ly migration -->
    YAML
    
    File.write(filepath, content)
    puts "Created post file: #{filepath}"
  end
  
  def add_redirects_to_post(post_file, link)
    content = File.read(post_file)
    
    # Parse front matter
    if content.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)
      front_matter = YAML.safe_load($1, permitted_classes: [Date, Time]) || {}
      body = $2
    else
      front_matter = {}
      body = content
    end
    
    # Add redirects
    redirects = front_matter['redirect_from'] || []
    redirects = [redirects] unless redirects.is_a?(Array)
    
    domain_redirect = "/#{link['domain']}/#{link['backhalf']}/"
    internal_redirect = "/l/#{link['backhalf'].sub(/\Apaj/, '')}/"
    
    redirects << domain_redirect unless redirects.include?(domain_redirect)
    redirects << internal_redirect unless redirects.include?(internal_redirect)
    
    front_matter['redirect_from'] = redirects
    
    # Write back to file
    new_content = "---\n#{front_matter.to_yaml.sub(/\A---\n/, '')}---\n#{body}"
    File.write(post_file, new_content)
  end
  
  def generate_external_filename(link)
    backhalf = link['backhalf']
    
    # Strip 'paj' prefix if present (case-sensitive, lowercase only)
    if backhalf.start_with?('paj')
      backhalf = backhalf[3..]
    end
    
    # Handle filename collisions with timestamp
    base_filename = backhalf
    if @used_filenames.include?(base_filename)
      timestamp = parse_created_date(link['created']).strftime('%Y%m%d%H%M%S')
      base_filename = "#{backhalf}_#{timestamp}"
    end
    
    @used_filenames.add(base_filename)
    base_filename
  end
  
def generate_external_link_content(link)
    # Escape double quotes in the title to avoid YAML syntax errors
    safe_title = link['title'].to_s.gsub('"', '\"')
    <<~YAML
        ---
        title: "#{safe_title}"
        redirect_from: /#{link['domain']}/#{link['backhalf']}/
        redirect_to: "#{link['long_url']}"
        ---
    YAML
end
  
  def parse_created_date(date_string)
    # Handle different date formats that might be in the JSON
    begin
      Date.parse(date_string)
    rescue Date::Error
      # Fallback to current date if parsing fails
      Date.today
    end
  end
end

# Run the migration
if __FILE__ == $0
  migrator = BitlyMigrator.new
  migrator.migrate
end