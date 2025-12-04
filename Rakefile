# frozen_string_literal: true

require "html-proofer"
require "fileutils"

desc 'Given a title as an argument, create a new post file'
task :write, [:title, :category] do |_t, args|
  NOW = Time.now.utc.freeze
  post_date = NOW.strftime('%Y-%m-%d')
  post_title = args.title.gsub(/\s/, '-').downcase
  filename = "#{post_date}-#{post_title}.markdown"
  path = File.join('_posts', filename)
  raise "Won't clobber #{path}" if File.exist?(path)
  File.open(path, 'w') do |file|
    file.write <<~FRONT_MATTER
      ---
      layout: post
      category: #{args.category}
      title: #{args.title}
      date: #{NOW.strftime('%Y-%m-%d %k:%M:%S')}
      ---
FRONT_MATTER
  end
  puts "Now open #{path} in an editor."
end

task :test => [:build, :validate_feeds] do
  options = { 
    cache: 
    { 
      timeframe: { external: "2w", internal: "1w" },
      cache_file: "html-proofer-cache.json",
      storage_dir: "./tmp/html-proofer-cache" 
   }
       }
  HTMLProofer.check_directory("./_site", options).run
end

task :build do
  sh "bundle exec jekyll build"
end

desc 'Validate XML feeds using W3C feedvalidator'
task :validate_feeds => :build do
  feeds = [
    '_site/feed.xml',
    '_site/careerbreak/rss.xml',
    '_site/careerbreak/atom.xml'
  ]
  
  # Check if feedvalidator is available
  feedvalidator_path = ENV['FEEDVALIDATOR_PATH'] || 'tmp/feedvalidator'
  feedvalidator_src = "#{feedvalidator_path}/src"
  
  unless File.directory?(feedvalidator_src)
    puts "Installing feedvalidator..."
    FileUtils.mkdir_p('tmp') unless File.directory?('tmp')
    
    # Remove existing directory if it exists but is incomplete
    FileUtils.rm_rf(feedvalidator_path) if File.directory?(feedvalidator_path)
    
    clone_output = `git clone --depth 1 https://github.com/w3c/feedvalidator.git #{feedvalidator_path} 2>&1`
    unless $?.success?
      error_msg = "Failed to clone feedvalidator: #{clone_output}"
      error_msg += "\nPlease ensure git is installed and you have network access."
      error_msg += "\nAlternatively, install it manually or set FEEDVALIDATOR_PATH"
      raise error_msg
    end
    
    unless File.directory?(feedvalidator_src)
      raise "feedvalidator src directory not found after cloning. Expected at: #{feedvalidator_src}"
    end
  end
  
  validator_script = File.expand_path(File.join(File.dirname(__FILE__), 'scripts', 'validate_feed.py'))
  unless File.exist?(validator_script)
    raise "Validator script not found at: #{validator_script}"
  end
  
  feeds.each do |feed_path|
    unless File.exist?(feed_path)
      puts "✗ #{feed_path} not found"
      raise "Feed file not found: #{feed_path}"
    end
    
    puts "Validating #{feed_path}..."
    
    # Use our wrapper script
    result = `python3 #{validator_script} #{feed_path} 2>&1`
    exit_code = $?.exitstatus
    
    # feedvalidator returns 0 for valid feeds, non-zero for invalid
    if exit_code == 0
      puts "✓ #{feed_path} is valid"
    else
      puts "✗ #{feed_path} has validation issues:"
      puts result
      raise "Feed validation failed for #{feed_path}"
    end
  end
  
  puts "All feeds validated successfully!"
end
