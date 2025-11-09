const BLOG_PATHNAME = "/blog/";

self.addEventListener("install", (event) => {
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener("fetch", (event) => {
  const request = event.request;

  if (request.mode !== "navigate") {
    return;
  }

  let url;
  try {
    url = new URL(request.url);
  } catch (error) {
    return;
  }

  if (url.pathname !== BLOG_PATHNAME) {
    return;
  }

  if (!url.searchParams.has("entry")) {
    return;
  }

  event.respondWith(handleLegacyEntryRequest(request, url));
});

async function handleLegacyEntryRequest(request, originalUrl) {
  const cleanUrl = new URL(originalUrl);
  cleanUrl.searchParams.delete("entry");

  try {
    const proxiedResponse = await fetch(cleanUrl.toString(), {
      method: "GET",
      headers: request.headers,
      credentials: "same-origin",
    });

    const body = await proxiedResponse.text();
    const headers = new Headers(proxiedResponse.headers);
    headers.set("content-type", "text/html; charset=utf-8");
    headers.set("x-entry-param-handled", "true");

    return new Response(body, {
      status: 410,
      statusText: "Gone",
      headers,
    });
  } catch (error) {
    const message = `
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Entry URL unavailable</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; margin: 2rem; line-height: 1.5; color: #043642; background: #fdf6e3; }
            code { background: rgba(0, 42, 53, 0.08); padding: 0.125rem 0.25rem; border-radius: 0.25rem; }
            a { color: #00796b; }
          </style>
        </head>
        <body>
          <h1>Entry URL no longer available</h1>
          <p>The requested blog entry URL is no longer supported. Please remove the <code>entry</code> query parameter and refresh the link.</p>
          <p><a href="${cleanUrl.pathname}">Return to the blog</a></p>
        </body>
      </html>
    `;

    return new Response(message, {
      status: 410,
      statusText: "Gone",
      headers: {
        "content-type": "text/html; charset=utf-8",
        "x-entry-param-handled": "error-fallback",
      },
    });
  }
}
