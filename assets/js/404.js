(function () {
  if (typeof window === "undefined") {
    return;
  }

  var actualUrl = window.location.href;
  var urlElement = document.getElementById("requested-url");
  if (urlElement) {
    urlElement.textContent = actualUrl;
  }

  var searchLink = document.getElementById("search-link");
  if (searchLink) {
    var pathname = window.location.pathname;
    if (pathname && pathname !== "/404.html") {
      var searchTerm = pathname
        .replace(/^\//, "")
        .replace(/\/$/, "")
        .replace(/\//g, " ")
        .replace(/-/g, " ")
        .replace(/\s+/g, " ")
        .trim();
      if (searchTerm) {
        var searchUrl = new URL("/search/", window.location.origin);
        searchUrl.searchParams.set("q", searchTerm);
        searchLink.href = searchUrl.pathname + searchUrl.search;
      }
    }
  }
})();

