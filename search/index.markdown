---
layout: default
title: Search
permalink: /search/
description: Explore the johnsy.com archives.
---

<h1>Search</h1>

<div id="pagefind-search" class="pagefind-search">
  <noscript>
    <p>Search requires JavaScript. Please enable it or browse the <a href="{{ '/blog/' | relative_url }}">blog archive</a>.</p>
  </noscript>
</div>

<link rel="stylesheet" href="{{ '/assets/pagefind/pagefind-ui.css' | relative_url }}" />
<script src="{{ '/assets/pagefind/pagefind-ui.js' | relative_url }}" defer></script>
<script>
  window.addEventListener("DOMContentLoaded", function () {
    if (window.PagefindUI) {
      new PagefindUI({
        element: "#pagefind-search",
        showImages: false,
        excerptLength: 30,
        bundlePath: "/assets/pagefind/",
        baseUrl: "/",
        debounceTimeout: 200,
        processResult: function (result) {
          if (!result) {
            return null;
          }

          if (result.url && /\/blog\/page\d+\//.test(result.url)) {
            return null;
          }

          if (result.meta && result.meta.title) {
            var updatedTitle = result.meta.title.replace(/\s+\|\s+johnsy\.com$/i, "");
            if (updatedTitle && updatedTitle.trim().length > 0) {
              result.meta.title = updatedTitle;
            }
          }

          return result;
        },
        translations: {
          placeholder: "Search johnsy.com",
        },
      });
    } else {
      var container = document.getElementById("pagefind-search");
      var fallback = document.createElement("p");
      fallback.textContent =
        "Search is temporarily unavailable. Try refreshing the page or visit the blog archive.";
      container.appendChild(fallback);
    }
  });
</script>

