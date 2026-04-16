# frozen_string_literal: true

module RssClubEnforcement
  module_function

  COMMON_WORDS = %w[
    the and to of a in is it that for on with as this be are was by at from or an
    if not have has but you we they their can will about more one all
  ].freeze

  def rot13(text)
    text.tr("A-Za-z", "N-ZA-Mn-za-m")
  end

  def english_score(text)
    downcased = text.to_s.downcase
    COMMON_WORDS.sum do |word|
      downcased.scan(/\b#{Regexp.escape(word)}\b/).size
    end
  end

  def rss_club_post?(document)
    return false unless document.respond_to?(:collection) && document.collection&.label == "posts"

    categories = Array(document.data["categories"])
    categories.include?("rss-club")
  end

  def probably_rot13_encoded?(content)
    content_score = english_score(content)
    decoded = rot13(content.to_s)
    decoded_score = english_score(decoded)
    decoded_score > content_score
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.each do |document|
    next unless RssClubEnforcement.rss_club_post?(document)

    document.data["noindex"] = true
    document.data["sitemap"] = false
  end
end

Jekyll::Hooks.register :documents, :pre_render do |document|
  next unless RssClubEnforcement.rss_club_post?(document)
  next unless RssClubEnforcement.probably_rot13_encoded?(document.content)

  document.content = RssClubEnforcement.rot13(document.content)
end
