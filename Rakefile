# frozen_string_literal: true

require "English"
require "html-proofer"
require "fileutils"

task :default => :test

desc "Given a title as an argument, create a new post file"
task :write, [:title, :category] do |_t, args|
  NOW = Time.now.utc.freeze
  post_date = NOW.strftime("%Y-%m-%d")
  post_title = args.title.gsub(/\s/, "-").downcase
  filename = "#{post_date}-#{post_title}.markdown"
  path = File.join("_posts", filename)
  raise "Won't clobber #{path}" if File.exist?(path)

  File.open(path, "w") do |file|
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

task :test => %i[build validate_feeds lighthouse_styles] do
  options = {
    cache:
    {
      timeframe: { external: "2w", internal: "1w" },
      cache_file: "html-proofer-cache.json",
      storage_dir: "./tmp/html-proofer-cache"
    },
    disable_external: false,
    allow_hash_href: true,
    ignore_status_codes: [0, 202, 403, 417, 429, 999], # Ignore network errors, async responses, access/booking errors, rate-limiting, unknown codes
    ignore_urls: [
      %r{//localhost},
      %r{//127\.0\.0\.1},
      %r{https?://(www\.)?realestate\.com\.au/},
      %r{https?://(www\.)?seek\.com\.au/}
    ]
  }

  begin
    HTMLProofer.check_directory("./_site", options).run
  rescue StandardError => e
    # Check if the error is related to external links
    raise unless e.message.include?("external") && ENV["STRICT_EXTERNAL_LINKS"].nil?

    puts "\n⚠️  External link check completed with warnings (non-breaking)"
    puts "Run with STRICT_EXTERNAL_LINKS=1 to fail the build on external link issues"
    puts "\nDetails: #{e.message}"
  end
end

desc "Run HTMLProofer validation with caching (for external link checking)"
task :validate_html => :build do
  require "html-proofer"

  options = {
    cache:
    {
      timeframe: { external: "2w", internal: "1w" },
      cache_file: "html-proofer-cache.json",
      storage_dir: "./tmp/html-proofer-cache"
    },
    disable_external: false,
    allow_hash_href: true,
    ignore_status_codes: [0, 202, 403, 417, 429, 999],
    ignore_urls: [
      %r{//localhost},
      %r{//127\.0\.0\.1},
      %r{https?://(www\.)?johnsy\.com/}, # Self-referential URLs fail during build
      %r{https?://(www\.)?realestate\.com\.au/},
      %r{https?://(www\.)?seek\.com\.au/},
      %r{http://news\.bbc\.co\.uk/2/hi/europe/1098192\.stm}, # Old HTTP BBC link - acceptable
      %r{http://(www\.)?mutt\.org/}, # Old HTTP mutt.org link - acceptable
      %r{https://ronjeffries\.com/xprog/articles/acsbowling}, # TODO: html-proofer reports false 301 timeout
      %r{https://ronjeffries\.com/xprog/articles/acsbowlingproceduralframescore}, # TODO: html-proofer reports false 301 timeout
      %r{https://signal\.me/#eu/} # Signal share URIs have app-specific hashes not on web
    ]
  }

  # Run HTMLProofer via system call to capture exit code
  # (HTMLProofer calls exit(1) directly, not raising an exception)
  success = system("ruby", "-e", <<~RUBY)
    require 'html-proofer'
    options = #{options.inspect}
    begin
      HTMLProofer.check_directory("./_site", options).run
    rescue SystemExit => e
      exit(e.status)
    end
  RUBY

  # If there were failures, fail the build
  unless success
    raise "HTML validation failed" if ENV["ALLOW_EXTERNAL_LINK_WARNINGS"].nil?

    puts "\n⚠️  HTML validation completed with warnings (non-breaking)"
    puts "Set ALLOW_EXTERNAL_LINK_WARNINGS=1 to suppress external link failures"
    # Don't fail the task

  end
end

desc "Generate style test page from CSS"
task :generate_style_test do
  sh "ruby scripts/generate_style_test.rb"
end

desc "Minify CSS assets for production"
task :minify_css do
  # Ensure pnpm is available (managed via mise from .tool-versions)
  raise "pnpm not found. Run 'mise install' to set up toolchain." unless system("which pnpm > /dev/null 2>&1")

  # Install dependencies if they are missing (cleancss comes from clean-css-cli)
  unless File.exist?("node_modules/.bin/cleancss")
    puts "Installing Node.js dependencies for minification..."
    raise "Failed to install Node.js dependencies" unless system("pnpm install")
  end

  targets = {
    "assets/css/style.css" => "assets/css/style.min.css",
    "assets/css/colors-light.css" => "assets/css/colors-light.min.css",
    "assets/css/colors-dark.css" => "assets/css/colors-dark.min.css"
  }

  targets.each do |source, destination|
    sh "pnpm exec cleancss -O2 --inline=none -o #{destination} #{source}"
  end
end

desc "Minify JavaScript assets for production"
task :minify_js do
  # Ensure pnpm is available (managed via mise from .tool-versions)
  raise "pnpm not found. Run 'mise install' to set up toolchain." unless system("which pnpm > /dev/null 2>&1")

  # Install dependencies if they are missing (terser)
  unless File.exist?("node_modules/.bin/terser")
    puts "Installing Node.js dependencies for minification..."
    raise "Failed to install Node.js dependencies" unless system("pnpm install")
  end

  js_files = [
    "assets/js/404.js",
    "assets/js/blog-entry-flash.js",
    "assets/js/mobile-menu.js",
    "assets/js/search.js",
    "blog-entry-sw.js"
  ]

  js_files.each do |source|
    destination = source.sub(/\.js$/, ".min.js")
    sh "pnpm exec terser #{source} --compress --mangle -o #{destination}"
  end
end

task :build => %i[generate_style_test minify_css minify_js] do
  sh "bundle exec jekyll build"
end

# Skip image optimization on CI; only do it for actual deployments/screenshots
desc "Optimize images in images/ directory"
task :optimize_images do
  if ENV["SKIP_IMAGE_OPTIMIZATION"]
    puts "Skipping image optimization (SKIP_IMAGE_OPTIMIZATION set)"
    return
  end

  images_dir = "images"
  unless File.directory?(images_dir)
    puts "Images directory not found"
    return
  end

  # Find all image files
  image_files = Dir.glob(File.join(images_dir, "**/*.{jpg,jpeg,png,gif}"), File::FNM_CASEFOLD)

  if image_files.empty?
    puts "No images found to optimize"
    return
  end

  puts "Optimizing #{image_files.length} images..."

  optimized_count = 0
  total_saved = 0

  image_files.each do |image|
    next if image.include?(".min.") # Skip already optimized files

    original_size = File.size(image)

    case File.extname(image).downcase
    when ".png"
      # Use pngquant if available, otherwise use built-in optimization
      if system("which pngquant > /dev/null 2>&1")
        `pngquant --force --speed 1 --output #{image} -- #{image}`
      elsif system("which optipng > /dev/null 2>&1")
        `optipng -o2 -strip all #{image}`
      end
    when ".jpg", ".jpeg"
      # Use jpegoptim if available
      `jpegoptim --max=85 --strip-all --quiet #{image}` if system("which jpegoptim > /dev/null 2>&1")
    end

    new_size = File.size(image)
    next unless new_size < original_size

    saved = original_size - new_size
    percent = (saved.to_f / original_size * 100).round(1)
    puts "  ✓ #{File.basename(image)}: #{percent}% reduction (#{new_size} bytes)"
    optimized_count += 1
    total_saved += saved
  end

  if optimized_count.positive?
    puts "✓ Optimized #{optimized_count} images, saved #{total_saved} bytes (#{(total_saved.to_f / 1024).round(1)} KB)"
  else
    puts "Images are already optimized"
  end
end

# Helper: Perform feed validation logic
def validate_feeds_internal
  feeds = [
    "_site/feed.xml",
    "_site/careerbreak/rss.xml",
    "_site/careerbreak/atom.xml"
  ]

  validator_script = File.expand_path(File.join(File.dirname(__FILE__), "scripts", "validate_feed.py"))
  raise "Validator script not found at: #{validator_script}" unless File.exist?(validator_script)

  feeds.each do |feed_path|
    unless File.exist?(feed_path)
      puts "✗ #{feed_path} not found"
      raise "Feed file not found: #{feed_path}"
    end

    puts "Validating #{feed_path}..."
    result = `python3 #{validator_script} #{feed_path} 2>&1`
    exit_code = $CHILD_STATUS.exitstatus

    if exit_code.zero?
      puts "✓ #{feed_path} is valid"
    else
      puts "✗ #{feed_path} has validation issues:"
      puts result
      raise "Feed validation failed for #{feed_path}"
    end
  end

  puts "All feeds validated successfully!"
end

desc "Validate XML feeds using W3C feedvalidator"
task :validate_feeds => :build do
  # Check if feedvalidator is available
  feedvalidator_path = ENV["FEEDVALIDATOR_PATH"] || "tmp/feedvalidator"
  feedvalidator_src = "#{feedvalidator_path}/src"

  unless File.directory?(feedvalidator_src)
    puts "Installing feedvalidator..."
    FileUtils.mkdir_p("tmp") unless File.directory?("tmp")

    # Remove existing directory if it exists but is incomplete
    FileUtils.rm_rf(feedvalidator_path) if File.directory?(feedvalidator_path)

    clone_output = `git clone --depth 1 https://github.com/w3c/feedvalidator.git #{feedvalidator_path} 2>&1`
    unless $CHILD_STATUS.success?
      error_msg = "Failed to clone feedvalidator: #{clone_output}"
      error_msg += "\nPlease ensure git is installed and you have network access."
      error_msg += "\nAlternatively, install it manually or set FEEDVALIDATOR_PATH"
      raise error_msg
    end

    raise "feedvalidator src directory not found after cloning. Expected at: #{feedvalidator_src}" unless File.directory?(feedvalidator_src)

    # Install required Python dependencies
    puts "Installing Python dependencies (html5lib)..."
    install_output = `python3 -m pip install --user html5lib 2>&1`
    unless $CHILD_STATUS.success?
      puts "Warning: Failed to install html5lib: #{install_output}"
      puts "Feed validation may not work correctly without html5lib"
    end
  end

  validate_feeds_internal
end

# Ensure the generated style test page exists when Lighthouse runs
def ensure_style_test_page
  style_test_page = File.join("_site", "style-test", "index.html")
  return if File.exist?(style_test_page)

  raise <<~MSG
    Style test page is missing at #{style_test_page}.
    Re-run without SKIP_BUILD (or provide a prebuilt _site) so Lighthouse can scan it.
  MSG
end

desc "Run Lighthouse CI accessibility tests on style test page (light mode)"
task :lighthouse_styles_light do
  # Build unless SKIP_BUILD is set; if skipped, ensure the style test page exists
  if ENV["SKIP_BUILD"] == "true"
    ensure_style_test_page
  else
    Rake::Task[:build].invoke
  end

  # Check if pnpm is available
  unless system("which pnpm > /dev/null 2>&1")
    puts "pnpm not found. Enabling via corepack..."
    raise "Failed to enable pnpm via corepack" unless system("corepack enable pnpm")
  end

  # Install dependencies if needed
  unless File.exist?("node_modules/@lhci")
    puts "Installing Lighthouse CI dependencies..."
    raise "Failed to install Node.js dependencies" unless system("pnpm install")
  end

  puts "Running Lighthouse CI on style test page (LIGHT MODE)..."
  raise "Lighthouse CI accessibility check failed (light mode) - color/font combinations do not meet WCAG standards" unless system("pnpm run lhci:styles:light")

  puts "✓ Light mode style accessibility checks passed!"
end

desc "Run Lighthouse CI accessibility tests on style test page (dark mode)"
task :lighthouse_styles_dark do
  # Build unless SKIP_BUILD is set; if skipped, ensure the style test page exists
  if ENV["SKIP_BUILD"] == "true"
    ensure_style_test_page
  else
    Rake::Task[:build].invoke
  end

  # Check if pnpm is available
  unless system("which pnpm > /dev/null 2>&1")
    puts "pnpm not found. Enabling via corepack..."
    raise "Failed to enable pnpm via corepack" unless system("corepack enable pnpm")
  end

  # Install dependencies if needed
  unless File.exist?("node_modules/@lhci")
    puts "Installing Lighthouse CI dependencies..."
    raise "Failed to install Node.js dependencies" unless system("pnpm install")
  end

  puts "Running Lighthouse CI on style test page (DARK MODE)..."
  raise "Lighthouse CI accessibility check failed (dark mode) - color/font combinations do not meet WCAG standards" unless system("pnpm run lhci:styles:dark")

  puts "✓ Dark mode style accessibility checks passed!"
end

desc "Run Lighthouse CI accessibility tests for both light and dark modes"
task :lighthouse_styles => %i[lighthouse_styles_light lighthouse_styles_dark] do
  puts "✓ All style accessibility checks passed (light and dark modes)!"
end

desc "Check external links for expiration (runs validate_html unless SKIP_VALIDATE_HTML=1)"
task :check_external_links do
  require "json"
  require "time"

  unless ENV["SKIP_VALIDATE_HTML"]
    begin
      Rake::Task["validate_html"].invoke
    rescue StandardError, SystemExit => e
      puts "validate_html failed (continuing to parse cache): #{e.message}"
    end
  end

  cache_file = "./tmp/html-proofer-cache/html-proofer-cache.json"

  unless File.exist?(cache_file)
    puts "Cache file not found at #{cache_file}"
    puts "Cache should have been populated by the :test task"
    return
  end

  cache_data = JSON.parse(File.read(cache_file))

  # html-proofer v4 nests links under "external"; older caches were flat
  link_cache = if cache_data.key?("external") && cache_data["external"].is_a?(Hash)
                 cache_data["external"]
               else
                 cache_data
               end

  links_by_status = {
    ok: [],
    expired: [],
    error: [],
    old: []
  }

  link_cache.each do |url, data|
    # Skip localhost/self-references and non-hash entries (e.g. version metadata)
    next if url.include?("localhost") || url.include?("127.0.0.1") || !data.is_a?(Hash)

    # html-proofer uses status_code; fall back to legacy status
    status = data["status_code"] || data["status"]
    status = status.to_i if status
    next unless data["time"] && status

    check_time = Time.parse(data["time"])
    age = [Time.now - check_time, 0].max
    age_days = (age / 86_400.0).round(1)

    link_info = { url: url, status: status, age: age_days, metadata: data["metadata"] }

    case status
    when 200, 202
      if age_days > 7
        links_by_status[:old] << link_info
      else
        links_by_status[:ok] << link_info
      end
    when 0, 999, 999_999
      links_by_status[:expired] << link_info
    when 301, 302, 303, 307, 308
      links_by_status[:error] << link_info.merge(type: "redirect")
    when 404, 410
      links_by_status[:error] << link_info.merge(type: "missing")
    else
      links_by_status[:error] << link_info.merge(type: "error")
    end
  end

  # Output as JSON to stdout for annotation parsing
  if ENV["JSON_OUTPUT"]
    report = {
      summary: {
        ok: links_by_status[:ok].length,
        expired: links_by_status[:expired].length,
        error: links_by_status[:error].length,
        old: links_by_status[:old].length
      },
      links: {
        ok: links_by_status[:ok],
        expired: links_by_status[:expired],
        error: links_by_status[:error],
        old: links_by_status[:old]
      }
    }
    puts JSON.generate(report)
    next
  end

  # Print human-readable report
  puts "\n#{'=' * 80}"
  puts "External Link Status Report".center(80)
  puts "=" * 80

  puts "\n📊 Summary:"
  puts "  ✓ Working:        #{links_by_status[:ok].length}"
  puts "  ⏰ Old (>7 days):  #{links_by_status[:old].length}"
  puts "  ⚠️  Error:         #{links_by_status[:error].length}"
  puts "  ❌ Expired:       #{links_by_status[:expired].length}"

  if links_by_status[:expired].any?
    puts "\n❌ EXPIRED EXTERNAL LINKS (#{links_by_status[:expired].length}):"
    puts "-" * 80
    links_by_status[:expired].each do |link|
      printf "  [HTTP %s] %-60s %d days old\n", link[:status], link[:url][0...60], link[:age]
      printf "           %s\n", link[:url][60..] if link[:url].length > 60
    end
    puts "\nAction: These links should be reviewed and updated or removed."
  end

  if links_by_status[:error].any?
    puts "\n⚠️  PROBLEMATIC EXTERNAL LINKS (#{links_by_status[:error].length}):"
    puts "-" * 80
    links_by_status[:error].each do |link|
      type = link[:type] || "error"
      printf "  [HTTP %s] %-60s %s\n", link[:status], link[:url][0...60], type
      printf "           %s\n", link[:url][60..] if link[:url].length > 60
    end
  end

  if links_by_status[:old].any?
    puts "\n⏰ CACHED FOR >7 DAYS (#{links_by_status[:old].length}):"
    puts "-" * 80
    links_by_status[:old].each do |link|
      printf "  [HTTP %s] %-60s %d days\n", link[:status], link[:url][0...60], link[:age]
    end
    puts "\nNote: These links may need rechecking for changes."
  end

  puts "\n#{'=' * 80}"

  if links_by_status[:expired].any? || links_by_status[:error].any?
    puts "\n⚠️  Found #{links_by_status[:expired].length + links_by_status[:error].length} problematic links."
  else
    puts "\n✓ All external links are in good status!"
  end
end

# ------------------------
# Local orchestration tasks
# ------------------------

# Base build to produce _site
desc "Base build for local flow"
task :base_build => :build

# Prepare style page and incrementally rebuild to materialize _site/style-test/index.html
desc "Prepare style page for Lighthouse (incremental rebuild)"
task :prepare_lighthouse_style => :generate_style_test do
  sh "bundle exec jekyll build --incremental"
end

# HTML validation (no build dependency)
desc "Validate HTML (no build)"
task :validate_html_only do
  options = {
    cache:
    {
      timeframe: { external: "2w", internal: "1w" },
      cache_file: "html-proofer-cache.json",
      storage_dir: "./tmp/html-proofer-cache"
    },
    disable_external: false,
    allow_hash_href: true,
    ignore_status_codes: [0, 202, 403, 417, 429, 999],
    ignore_urls: [
      %r{//localhost},
      %r{//127\.0\.0\.1},
      %r{https?://(www\.)?johnsy\.com/},
      %r{https?://(www\.)?realestate\.com\.au/},
      %r{https?://(www\.)?seek\.com\.au/},
      %r{http://news\.bbc\.co\.uk/2/hi/europe/1098192\.stm},
      %r{http://(www\.)?mutt\.org/},
      %r{https://ronjeffries\.com/xprog/articles/acsbowling},
      %r{https://ronjeffries\.com/xprog/articles/acsbowlingproceduralframescore},
      %r{https://signal\.me/#eu/}
    ]
  }

  success = system("ruby", "-e", <<~RUBY)
    require 'html-proofer'
    options = #{options.inspect}
    begin
      HTMLProofer.check_directory("./_site", options).run
    rescue SystemExit => e
      exit(e.status)
    end
  RUBY

  unless success
    raise "HTML validation failed" if ENV["ALLOW_EXTERNAL_LINK_WARNINGS"].nil?

    puts "\n⚠️  HTML validation completed with warnings (non-breaking)"

  end
end

# Feed validation (no build dependency)
desc "Validate XML feeds (no build)"
task :validate_feeds_only do
  validate_feeds_internal
end

# External links report (no implicit HTML validation)
desc "Check external links only (skip validate_html)"
task :check_external_links_only do
  ENV["SKIP_VALIDATE_HTML"] = "1"
  Rake::Task["check_external_links"].invoke
end

# Build search index without deleting _site
desc "Build search index (Pagefind) without cleaning _site"
task :build_search_index do
  sh "npx --yes pagefind --site _site --output-path assets/pagefind --force-language en"
end

# Lighthouse wrappers respecting SKIP_BUILD and depending on style prep
desc "Run Lighthouse (light) without rebuild"
task :lighthouse_styles_light_only => :prepare_lighthouse_style do
  ENV["SKIP_BUILD"] = "true"
  Rake::Task[:lighthouse_styles_light].invoke
end

desc "Run Lighthouse (dark) without rebuild"
task :lighthouse_styles_dark_only => :prepare_lighthouse_style do
  ENV["SKIP_BUILD"] = "true"
  Rake::Task[:lighthouse_styles_dark].invoke
end

# README refresh after search index
desc "Refresh README with TOC after search index"
task :refresh_readme => :build_search_index do
  sh "ruby scripts/update_readme.rb"
end

desc "Don't deploy broken JSON"
task :validate_structured_data do
  sh "bash scripts/validate-structured-data.sh"
end

# Stage 2: run validations and preparations in parallel
multitask :stage_two => %i[
  prepare_lighthouse_style
  validate_structured_data
  validate_feeds_only
  validate_html_only
  check_external_links_only
  build_search_index
]

# Stage 3: run Lighthouse checks in parallel (each depends on style prep)
multitask :lighthouse_checks => %i[
  lighthouse_styles_light_only
  lighthouse_styles_dark_only
]

# Deploy gate: ensure all validations + README refresh done
desc "Ready to deploy gate"
task :ready_to_deploy => %i[
  validate_structured_data
  validate_feeds_only
  validate_html_only
  check_external_links_only
  lighthouse_checks
  refresh_readme
] do
  puts "✓ All validations complete and README refreshed. Ready to deploy."
end

# Full local flow orchestrator
desc "Run full local flow: build, parallel checks, lighthouse, README, deploy gate"
task :full_flow => %i[base_build stage_two ready_to_deploy]
