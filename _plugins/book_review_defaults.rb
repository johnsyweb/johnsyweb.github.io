# frozen_string_literal: true

require_relative "../scripts/lib/post_title"
require_relative "../scripts/lib/book_review_title"

# Apply resolved titles and book-review defaults after posts are read.
Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.each do |document|
    resolved = PostTitle.resolve(document.data)
    # Overwrite Jekyll's filename-titleized fallback when a strategy provides a title.
    document.data["title"] = resolved if resolved

    next unless BookReviewTitle.book_review?(document.data)

    cover = document.data["cover"].to_s.strip
    og_image = document.data["og_image"].to_s.strip
    document.data["og_image"] = cover if og_image.empty? && !cover.empty?
  end
end
