# frozen_string_literal: true

# Book-review identity and title derivation (used by strategy + Jekyll plugin).
module BookReviewTitle
  module_function

  def book_review?(front_matter)
    layout = front_matter["layout"].to_s
    categories = Array(front_matter["categories"]).map(&:to_s)
    layout == "review" || categories.include?("books")
  end

  def derive(book_title, book_author)
    title = book_title.to_s.strip
    author = book_author.to_s.strip
    return if title.empty? || author.empty?

    "Book review: #{title} by #{author}"
  end

  def for_review(front_matter)
    return unless book_review?(front_matter)

    derive(front_matter["book_title"], front_matter["book_author"])
  end
end
