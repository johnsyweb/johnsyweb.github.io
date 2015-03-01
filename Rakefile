desc "Given a title as an argument, create a new post file"
task :write, [:title, :category] do |_t, args|
  NOW = Time.now
  filename = "#{NOW.strftime('%Y-%m-%d')}-#{args.title.gsub(/\s/, '-').downcase}.markdown"
  path = File.join("_posts", filename)
  raise RuntimeError.new("Won't clobber #{path}") if File.exist?(path)
  File.open(path, 'w') do |file|
    file.write <<-EOS
---
layout: post
category: #{args.category}
title: #{args.title}
date: #{NOW.strftime('%Y-%m-%d %k:%M:%S')}
---
EOS
  end
  puts "Now open #{path} in an editor."
end
