# frozen_string_literal: true

# Resolve a post title from front matter via registered strategies.
# Strategies live in scripts/lib/post_title_strategies/ and are loaded automatically.
module PostTitle
  module_function

  def strategies
    @strategies ||= []
  end

  def add_strategy(strategy)
    strategies << strategy
    strategies.sort_by!(&:priority)
  end

  def resolve(front_matter)
    strategies.each do |strategy|
      title = strategy.resolve(front_matter)
      next if title.nil?

      stripped = title.to_s.strip
      return stripped unless stripped.empty?
    end
    nil
  end
end

Dir[File.join(__dir__, "post_title_strategies", "*.rb")].sort.each { |path| require path }
