# frozen_string_literal: true

require "html-proofer"
require "fileutils"

task :default => :test

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

task :test => [:build, :validate_feeds, :lighthouse_styles] do
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

desc 'Generate style test page from CSS'
task :generate_style_test do
  sh "ruby scripts/generate_style_test.rb"
end

desc 'Minify CSS assets for production'
task :minify_css do
  # Ensure pnpm is available (managed via mise from .tool-versions)
  unless system('which pnpm > /dev/null 2>&1')
    raise "pnpm not found. Run 'mise install' to set up toolchain."
  end

  # Install dependencies if they are missing (cleancss comes from clean-css-cli)
  unless File.exist?('node_modules/.bin/cleancss')
    puts "Installing Node.js dependencies for minification..."
    raise "Failed to install Node.js dependencies" unless system('pnpm install')
  end

  targets = {
    'assets/css/style.css' => 'assets/css/style.min.css',
    'assets/css/colors-light.css' => 'assets/css/colors-light.min.css',
    'assets/css/colors-dark.css' => 'assets/css/colors-dark.min.css'
  }

  targets.each do |source, destination|
    sh "pnpm exec cleancss -O2 --inline=none -o #{destination} #{source}"
  end
end

task :build => [:generate_style_test, :minify_css, :optimize_images] do
  sh "bundle exec jekyll build"
end

desc 'Optimize images in images/ directory'
task :optimize_images do
  images_dir = 'images'
  unless File.directory?(images_dir)
    puts "Images directory not found"
    return
  end

  # Find all image files
  image_files = Dir.glob(File.join(images_dir, '**/*.{jpg,jpeg,png,gif}'), File::FNM_CASEFOLD)
  
  if image_files.empty?
    puts "No images found to optimize"
    return
  end

  puts "Optimizing #{image_files.length} images..."
  
  optimized_count = 0
  total_saved = 0
  
  image_files.each do |image|
    next if image.include?('.min.')  # Skip already optimized files
    
    original_size = File.size(image)
    
    case File.extname(image).downcase
    when '.png'
      # Use pngquant if available, otherwise use built-in optimization
      if system("which pngquant > /dev/null 2>&1")
        `pngquant --force --speed 1 --output #{image} -- #{image}`
      elsif system("which optipng > /dev/null 2>&1")
        `optipng -o2 -strip all #{image}`
      end
    when '.jpg', '.jpeg'
      # Use jpegoptim if available
      if system("which jpegoptim > /dev/null 2>&1")
        `jpegoptim --max=85 --strip-all --quiet #{image}`
      end
    end
    
    new_size = File.size(image)
    if new_size < original_size
      saved = original_size - new_size
      percent = (saved.to_f / original_size * 100).round(1)
      puts "  ✓ #{File.basename(image)}: #{percent}% reduction (#{new_size} bytes)"
      optimized_count += 1
      total_saved += saved
    end
  end
  
  if optimized_count > 0
    puts "✓ Optimized #{optimized_count} images, saved #{total_saved} bytes (#{(total_saved.to_f / 1024).round(1)} KB)"
  else
    puts "Images are already optimized"
  end
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

desc 'Run Lighthouse CI accessibility tests on style test page (light mode)'
task :lighthouse_styles_light => :build do
  # Check if pnpm is available
  unless system('which pnpm > /dev/null 2>&1')
    puts "pnpm not found. Enabling via corepack..."
    unless system('corepack enable pnpm')
      raise "Failed to enable pnpm via corepack"
    end
  end
  
  # Install dependencies if needed
  unless File.exist?('node_modules/@lhci')
    puts "Installing Lighthouse CI dependencies..."
    unless system('pnpm install')
      raise "Failed to install Node.js dependencies"
    end
  end
  
  puts "Running Lighthouse CI on style test page (LIGHT MODE)..."
  unless system('pnpm run lhci:styles:light')
    raise "Lighthouse CI accessibility check failed (light mode) - color/font combinations do not meet WCAG standards"
  end
  
  puts "✓ Light mode style accessibility checks passed!"
end

desc 'Run Lighthouse CI accessibility tests on style test page (dark mode)'
task :lighthouse_styles_dark => :build do
  # Check if pnpm is available
  unless system('which pnpm > /dev/null 2>&1')
    puts "pnpm not found. Enabling via corepack..."
    unless system('corepack enable pnpm')
      raise "Failed to enable pnpm via corepack"
    end
  end
  
  # Install dependencies if needed
  unless File.exist?('node_modules/@lhci')
    puts "Installing Lighthouse CI dependencies..."
    unless system('pnpm install')
      raise "Failed to install Node.js dependencies"
    end
  end
  
  puts "Running Lighthouse CI on style test page (DARK MODE)..."
  unless system('pnpm run lhci:styles:dark')
    raise "Lighthouse CI accessibility check failed (dark mode) - color/font combinations do not meet WCAG standards"
  end
  
  puts "✓ Dark mode style accessibility checks passed!"
end

desc 'Run Lighthouse CI accessibility tests for both light and dark modes'
task :lighthouse_styles => [:lighthouse_styles_light, :lighthouse_styles_dark] do
  puts "✓ All style accessibility checks passed (light and dark modes)!"
end
