---
layout: post
title: Moving back to www
date: 2026-01-07 21:30:00 +00:00
categories:
 - blog
 - meta
---

After years of hosting this site at the apex domain `johnsy.com`, I'm moving back to `www.johnsy.com`. Much earlier versions of this site lived at the www subdomain, so this is something of a homecoming. If you've bookmarked the site or have links pointing to the old URL, no need to worry; everything will redirect automatically.

## Why the change?

The key factor: **GitHub Pages only redirects in one direction**. When you configure a www subdomain as your custom domain, GitHub automatically redirects apex domain visitors to www. But it doesn't work the other way around—if you use an apex domain, visitors to www won't be redirected.

With the apex configuration, visitors hitting www weren't redirected, which risks split signals and confusion. Moving to www sets a single canonical URL and redirects apex traffic automatically.

Beyond the redirect behaviour, there are other benefits:

**Better infrastructure**: GitHub Pages handles SSL certificates and CDN routing more reliably for www subdomains.

**Future-proofing**: DNS changes on GitHub's end are handled automatically without requiring manual configuration updates.

**Following best practices**: GitHub [recommends using a www subdomain][gh-pages-custom-domain] for exactly these reasons.

## What's changed?

All internal links now use Jekyll's configuration and built-in linking:
- Asset references use `{{ site.url }}` to dynamically point to the correct domain
- Inter-post links use `{% post_url %}` for stable references regardless of URL structure

The DNS configuration has been updated:
- `www.johnsy.com` now has a CNAME record pointing to `johnsyweb.github.io`
- `johnsy.com` retains its A records and automatically redirects to the www version

## What you need to do

Nothing! If you visit `johnsy.com` or any old URLs, you'll be automatically redirected to the new www address. Your RSS feeds will continue to work, and your bookmarks will still get you here.

If you maintain links to this site, updating them to use `www.johnsy.com` would be appreciated, but it's not required; redirects will handle the transition.

## The process

This migration involved:
1. Updating [_config.yml] to set `www.johnsy.com` as the canonical URL
2. Replacing hardcoded domain references with Jekyll variables and linking functions
3. Updating DNS configuration
4. Setting GitHub Pages to use www as the custom domain
5. Running full validation to ensure no broken links

Using `{{ site.url }}` and `{% post_url %}` trims most hardcoded URLs on the main site. Some microsites keep their own settings, but most pages now follow the config, which should make future changes simpler.

If you spot anything odd after the move, please drop me a note via [the contact page]({{ site.url }}/contact/) or open an issue on [the GitHub repository][repo-issues].

I've also enabled uptime monitoring with UptimeRobot (great name); on the free plan it emails me if anything goes sideways during the transition.

Welcome to the new address!

<!-- Links -->

[gh-pages-custom-domain]: https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages
[_config.yml]: https://github.com/johnsyweb/johnsyweb.github.io/blob/main/_config.yml
[repo-issues]: https://github.com/johnsyweb/johnsyweb.github.io/issues
[UptimeRobot]: https://uptimerobot.com
