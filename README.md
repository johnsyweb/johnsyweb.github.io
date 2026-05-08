# johnsyweb.github.io

A complete waste of cyberspace.

## Development

### Toolchain (mise)

This project uses [mise](https://mise.jdx.dev) for Ruby, Node, and pnpm. Do not rely on system Ruby or Bundler.

1. Install mise: <https://mise.jdx.dev>
2. In this repo run: `mise run bootstrap`
3. Start local development with: `mise run server`
4. Use `mise exec -- rake …` for ad hoc tasks (or ensure your shell has `mise activate` so `rake` and `pnpm` come from mise).

All Rake tasks run subshell commands (bundle, jekyll, pnpm, node, ruby) via `mise exec`, so builds and tests use the versions in `.mise.toml`.

`mise run server` runs four processes:
- **Initial image conversion**: Generates missing WebP assets before Jekyll starts
- **CSS watcher**: Automatically minifies CSS files when they change
- **JS watcher**: Automatically minifies JavaScript files when they change
- **Image watcher**: Regenerates WebP assets when `.jpg`, `.jpeg`, or `.png` files change
- **Jekyll server**: Serves the site with live reload on http://localhost:4000

```bash
mise run server
```

All file changes are detected automatically, and your browser will refresh when Jekyll content changes.

### Testing

The full test suite is `rake test` (build, HTML/feed validation, Lighthouse style checks). On GitHub Actions, Nu Html Checker (`vnu`) runs on the built site and the workflow fails if it reports errors. Run tests with mise so Ruby and Node match the project:

```bash
mise exec -- rake test
```

### Pre-push HTML validation hook

To run the same HTML validation class as CI before every push, enable the
repository-managed hooks path once per clone:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/pre-push
```

If Docker is running, the hook also runs `vnu` (the same HTML validator class
used in CI). If Docker is unavailable, the hook warns and skips `vnu`.

### Syndication

The blog exposes **RSS 2.0** at **`/rss.xml`** (canonical) and **`/feed.xml`** (same feed for existing subscribers), and **Atom** at `/atom.xml` (production: `https://www.johnsy.com/rss.xml`, `https://www.johnsy.com/feed.xml`, `https://www.johnsy.com/atom.xml`). Main feed titles use `_config.yml` **`feed_title`** (the site **`name`** stays the domain for header branding). The full test run validates these feeds (and the career break feeds) after a Jekyll build.

## Microsites Showcase

The homepage features a showcase of microsites, similar to the parkrun utilities page. Microsites are configured in `_data/microsites.yml` and displayed using the `utility-card.html` include.

### Adding a New Microsite

1. Open `_data/microsites.yml`
2. Add a new entry under the `microsites:` array with the following structure:

```yaml
- id: unique-id
  title: Display Name
  url: https://www.johnsy.com/path/
  image: https://www.johnsy.com/path/og-image.png
  image_alt: "Alt text for the preview image"
  description: "Brief description of what the microsite does"
  purpose: "One-line purpose statement"
  features:
    - Feature one
    - Feature two
    - Feature three
  seo:
    keywords: "comma, separated, keywords"
    schema_type: "WebApplication"  # or "SoftwareApplication"
    audience: "Target audience description"
```

3. The microsite will automatically appear on the homepage
4. If the microsite URL is under `www.johnsy.com` and ends with `/`, its sitemap will be automatically included in `sitemap-index.xml`

### Setting Up URL Redirects

To create a redirect from one URL to another (e.g., `/qrty/` → `/QRTY/`):

1. Create a directory with the redirect source path (e.g., `qrty/`)
2. Add an `index.html` file with front matter:

```yaml
---
redirect_to: https://www.johnsy.com/QRTY/
permalink: /qrty/
---
```

The `jekyll-redirect-from` plugin will generate a 301 redirect.

## Search

This site uses [Pagefind](https://pagefind.app/) for client-side search. After adding or updating content, regenerate the search index before committing:

```bash
./scripts/update_search.sh
```

The script builds the site, runs Pagefind, and refreshes the assets in `assets/pagefind/`. If you are using a custom Ruby version manager, ensure the environment can run `bundle exec jekyll build` first.



<!-- BEGIN TOC -->
## Website Sections

- [About](https://www.johnsy.com/about/)
- [Blog](https://www.johnsy.com/blog/)
- [Contact](https://www.johnsy.com/contact/)

## Recent Blog Posts

- 2026-05-08: [Iron Maiden: Burning Ambition](https://www.johnsy.com/blog/2026/05/08/burning-ambition/)
- 2026-05-06: [Conquer Cancer - Hour One](https://www.johnsy.com/blog/2026/05/06/conquer-cancer---hour-one/)
- 2026-05-02: [What is going on with Apple's User Interfaces?](https://www.johnsy.com/blog/2026/05/02/what-is-going-on-with-apple's-user-interfaces?/)
- 2026-05-02: [Coburg parkrun event #517](https://www.johnsy.com/blog/2026/05/02/coburg-parkrun-event-#517/)
- 2026-04-28: [I'm taking on Conquer Cancer and I need your support!](https://www.johnsy.com/blog/2026/04/28/i'm-taking-on-conquer-cancer-and-i-need-your-support!/)
- 2026-04-25: [Studley parkrun event #466](https://www.johnsy.com/blog/2026/04/25/studley-parkrun-event-#466/)
- 2026-04-25: [Radio Paradise](https://www.johnsy.com/blog/2026/04/25/radio-paradise/)
- 2026-04-18: [Cruickshank Park parkrun event #11](https://www.johnsy.com/blog/2026/04/18/cruickshank-park-parkrun-event-#11/)
- 2026-04-16: [Plan for Failure](https://www.johnsy.com/blog/2026/04/16/plan-for-failure/)
- 2026-04-14: [Still Keeping in the Development Loop](https://www.johnsy.com/blog/2026/04/14/still-keeping-in-the-development-loop/)

<!-- END TOC -->
