# frozen_string_literal: true

require_relative "../book_review_title"

# Book reviews derive their title from book_title + book_author.
class BookReviewTitleStrategy
  def priority
    10
  end

  def resolve(front_matter)
    BookReviewTitle.for_review(front_matter)
  end
end

PostTitle.add_strategy(BookReviewTitleStrategy.new)
