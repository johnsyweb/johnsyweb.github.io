(function () {
  window.addEventListener("DOMContentLoaded", function () {
    if (!window.PagefindUI) {
      var container = document.getElementById("pagefind-search");
      if (container) {
        var fallback = document.createElement("p");
        fallback.textContent =
          "Search is temporarily unavailable. Try refreshing the page or visit the blog archive.";
        container.appendChild(fallback);
      }
      return;
    }

    var params = new URLSearchParams(window.location.search);
    var initialTerm = params.get("q") || "";

    var pagefind = new PagefindUI({
      element: "#pagefind-search",
      showImages: false,
      showSubResults: false,
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

    if (initialTerm) {
      pagefind.triggerSearch(initialTerm);
    }

    window.addEventListener("pagefind-ui-search", function (event) {
      var searchTerm = event.detail && event.detail.term;
      if (typeof searchTerm !== "string") {
        return;
      }

      if (window.history && window.history.replaceState) {
        var url = new URL(window.location.href);
        if (searchTerm) {
          url.searchParams.set("q", searchTerm);
        } else {
          url.searchParams.delete("q");
        }
        window.history.replaceState({}, "", url.toString());
      }
    });

    window.requestAnimationFrame(function () {
      var input = document.querySelector(".pagefind-ui__search-input");
      if (input && typeof input.focus === "function") {
        input.focus();
        if (initialTerm) {
          input.value = initialTerm;
        }
      }
    });
  });
})();

