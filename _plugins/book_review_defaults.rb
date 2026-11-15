# frozen_string_literal: true

# Derive review titles from book metadata when front matter omits title.
module BookReviewDefaults
  module_function

  def book_review?(document)
    return false unless document.respond_to?(:data)

    layout = document.data["layout"].to_s
    categories = Array(document.data["categories"]).map(&:to_s)
    layout == "review" || categories.include?("books")
  end

  def derived_title(book_title, book_author)
    "Book review: #{book_title} by #{book_author}"
  end

  def apply!(document)
    return unless book_review?(document)

    book_title = document.data["book_title"].to_s.strip
    book_author = document.data["book_author"].to_s.strip
    return if book_title.empty? || book_author.empty?

    # Always derive: Jekyll otherwise titleizes the filename when front matter
    # omits title, which would leave a bare slug like "Theo Of Golden".
    document.data["title"] = derived_title(book_title, book_author)

    cover = document.data["cover"].to_s.strip
    og_image = document.data["og_image"].to_s.strip
    document.data["og_image"] = cover if og_image.empty? && !cover.empty?
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.each { |document| BookReviewDefaults.apply!(document) }
end
