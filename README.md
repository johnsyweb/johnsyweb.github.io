# johnsyweb.github.io

A complete waste of cyberspace.

## Development

### Toolchain (mise)

This project uses [mise](https://mise.jdx.dev) for Ruby, Node, and pnpm. Do not rely on system Ruby or Bundler.

1. Install mise: <https://mise.jdx.dev>
2. In this repo run: `mise install`
3. Use `mise exec -- rake …` (or ensure your shell has `mise activate` so `rake` and `pnpm` come from mise).

All Rake tasks run subshell commands (bundle, jekyll, pnpm, node, ruby) via `mise exec`, so builds and tests use the versions in `.tool-versions`.

To start the development server with automatic CSS and JavaScript minification, plus Jekyll live reload:

```bash
pnpm run dev
```

(This requires `pnpm` to be on PATH from mise, e.g. `mise install` then `mise exec -- pnpm run dev` or a shell with `mise activate`.)

This command runs three watch processes in parallel:
- **CSS watcher**: Automatically minifies CSS files when they change
- **JS watcher**: Automatically minifies JavaScript files when they change  
- **Jekyll server**: Serves the site with live reload on http://localhost:4000

All file changes are detected automatically, and your browser will refresh when Jekyll content changes.

### Testing

The full test suite is `rake test` (build, HTML/feed validation, Lighthouse style checks). Run it with mise so Ruby and Node match the project:

```bash
mise exec -- rake test
```

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

- 2026-02-17: [On Writing Pull Request Descriptions Well: The Five Cs](https://www.johnsy.com/blog/2026/02/17/on-writing-pull-request-descriptions-well/)
- 2026-01-21: [Automating Distraction Blocking with Pi-hole v6 and dedistracter](https://www.johnsy.com/blog/2026/01/21/dedistracter-pihole-scheduler/)
- 2026-01-20: [Can we reunite a lost AirPod with its owner?](https://www.johnsy.com/blog/2026/01/20/can-we-reunite-a-lost-airpod-with-its-owner/)
- 2026-01-15: [Two Bays Trail Run 2026](https://www.johnsy.com/blog/2026/01/15/two-bays-trail-run-2026/)
- 2026-01-07: [Moving back to www](https://www.johnsy.com/blog/2026/01/07/moving-to-www/)
- 2025-12-15: [Accessible colours beat Solarized (and why that matters)](https://www.johnsy.com/blog/2025/12/15/accessible-colours-over-solarized/)
- 2025-12-08: [National Crossword Solvers Day](https://www.johnsy.com/blog/2025/12/08/national-crossword-solvers-day/)
- 2025-12-01: [Forty-two](https://www.johnsy.com/blog/2025/12/01/forty-two/)
- 2025-11-29: [Counterpoints to &ldquo;Comparison is the Thief of Joy&rdquo;](https://www.johnsy.com/blog/2025/11/29/counterpoints-to-comparison-is-the-thief-of-joy/)
- 2025-11-06: [Foretoken — parkrun finish tokens on your phone](https://www.johnsy.com/blog/2025/11/06/foretoken/)

<!-- END TOC -->
