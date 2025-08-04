# frozen_string_literal: true

require "html-proofer"

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

task :test => :build do
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
