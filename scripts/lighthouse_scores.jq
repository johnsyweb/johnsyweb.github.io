# Extract URL and category scores from Lighthouse JSON report
# Output: url|performance|accessibility|best-practices|seo|pwa (all scores 0-100)

[
  .finalUrl // .requestedUrl // "unknown",
  ((.categories.performance.score // 0) * 100 | floor),
  ((.categories.accessibility.score // 0) * 100 | floor),
  ((.categories["best-practices"].score // 0) * 100 | floor),
  ((.categories.seo.score // 0) * 100 | floor),
  ((.categories.pwa.score // 0) * 100 | floor)
] | join("|")
