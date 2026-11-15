# frozen_string_literal: true

# Default: use an explicit title from front matter.
class FrontMatterTitleStrategy
  def priority
    100
  end

  def resolve(front_matter)
    title = front_matter["title"].to_s.strip
    title unless title.empty?
  end
end

PostTitle.add_strategy(FrontMatterTitleStrategy.new)
