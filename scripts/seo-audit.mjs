#!/usr/bin/env node
import { promises as fs } from 'fs';
import path from 'path';

const siteDir = process.env.SITE_DIR || '_site';
const minDescriptionLength = Number(process.env.SEO_DESC_MIN_HARD || 70);
const minTitleLength = Number(process.env.SEO_TITLE_MIN_HARD || 20);
const maxDuplicatePages = Number(process.env.SEO_DESC_DUP_MAX_PAGES || 1);
const dupSeverity = (process.env.SEO_DESC_DUP_SEVERITY || 'error').toLowerCase();
const includePostsInDupScan = process.env.SEO_DESC_DUP_INCLUDE_POSTS !== '0';

const enforcePathPrefixes = ['/', '/about/', '/contact/', '/search/', '/blog/', '/careerbreak/', '/404.html'];

function shouldEnforce(urlPath) {
  return enforcePathPrefixes.some((prefix) => {
    if (prefix === '/') {
      return urlPath === '/';
    }
    return urlPath === prefix || urlPath.startsWith(prefix);
  });
}

async function walkHtmlFiles(dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  const files = await Promise.all(
    entries.map(async (entry) => {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        return walkHtmlFiles(fullPath);
      }
      if (entry.isFile() && entry.name.endsWith('.html')) {
        return [fullPath];
      }
      return [];
    })
  );
  return files.flat();
}

function extractFirst(content, pattern) {
  const match = content.match(pattern);
  return match ? match[1].trim() : '';
}

function stripTags(value) {
  return value.replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();
}

function filePathToUrlPath(filePath) {
  const normalized = filePath.replace(/\\/g, '/');
  const absIdx = normalized.indexOf('/_site/');
  const relIdx = normalized.indexOf('_site/');
  let rel = normalized;

  if (absIdx >= 0) {
    rel = normalized.slice(absIdx + '/_site'.length);
  } else if (relIdx === 0) {
    rel = normalized.slice('_site'.length);
  }

  if (rel === '/index.html') {
    return '/';
  }
  if (rel.endsWith('/index.html')) {
    return `${rel.slice(0, -'index.html'.length)}`;
  }
  return rel;
}

function normalizePath(urlPath) {
  if (!urlPath) {
    return '/';
  }

  if (urlPath === '/404.html') {
    return urlPath;
  }

  return urlPath.endsWith('/') ? urlPath : `${urlPath}/`;
}

function isBlogPostPath(urlPath) {
  return /^\/blog\/\d{4}\/\d{2}\/\d{2}\//.test(urlPath);
}

function isRedirectStub(content) {
  return /<meta[^>]+http-equiv=["']refresh["']/i.test(content) ||
    /location\s*=\s*["'][^"']+["']/i.test(content) ||
    /window\.location/i.test(content);
}

function isNoindexPage(content) {
  return /<meta[^>]+name=["']robots["'][^>]+content=["'][^"']*noindex/i.test(content);
}

function canonicalPathFromHtml(content, fallbackPath) {
  const canonicalUrl = extractFirst(content, /<link[^>]+rel=["']canonical["'][^>]+href=["']([^"']+)["'][^>]*>/i);
  if (!canonicalUrl) {
    return fallbackPath;
  }
  try {
    const url = new URL(canonicalUrl);
    return url.pathname.endsWith('/') || url.pathname === '/404.html' ? url.pathname : `${url.pathname}/`;
  } catch {
    return canonicalUrl;
  }
}

async function readSiteDescriptionFallback() {
  try {
    const configPath = path.join(process.cwd(), '_config.yml');
    const configText = await fs.readFile(configPath, 'utf8');
    const match = configText.match(/^\s*description:\s*(.+)\s*$/m);
    if (!match) {
      return '';
    }

    let value = match[1].trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    return value;
  } catch {
    return '';
  }
}

async function run() {
  const allHtmlFiles = await walkHtmlFiles(siteDir);
  const siteDescriptionFallback = await readSiteDescriptionFallback();
  const checked = [];
  const failures = [];
  const warnings = [];
  const descriptions = new Map();
  const seenCanonicalPaths = new Set();

  for (const file of allHtmlFiles) {
    const html = await fs.readFile(file, 'utf8');
    const fallbackPath = normalizePath(filePathToUrlPath(file));
    const urlPath = normalizePath(canonicalPathFromHtml(html, fallbackPath));

    if (isRedirectStub(html)) {
      continue;
    }

    if (isNoindexPage(html)) {
      continue;
    }

    // Only audit canonical pages once.
    if (urlPath !== fallbackPath || seenCanonicalPaths.has(urlPath)) {
      continue;
    }
    seenCanonicalPaths.add(urlPath);

    const enforce = shouldEnforce(urlPath);

    if (!enforce) {
      continue;
    }

    const h1Count = (html.match(/<h1\b/gi) || []).length;
    const title = stripTags(extractFirst(html, /<title>([\s\S]*?)<\/title>/i));
    const description = extractFirst(html, /<meta[^>]+name=["']description["'][^>]+content="([^"]*)"[^>]*>/i);
    const isBlogPost = isBlogPostPath(urlPath);

    checked.push({ file, urlPath, h1Count, titleLength: title.length, descriptionLength: description.length, description });

    if (h1Count !== 1) {
      failures.push(`${urlPath}: expected exactly 1 h1, found ${h1Count}`);
    }

    if (!description) {
      if (isBlogPost) {
        warnings.push(`${urlPath}: missing meta description`);
      } else {
        failures.push(`${urlPath}: missing meta description`);
      }
    } else if (siteDescriptionFallback && description === siteDescriptionFallback) {
      failures.push(`${urlPath}: meta description is the site-level fallback text`);
    } else if (description.length < minDescriptionLength) {
      if (isBlogPost) {
        warnings.push(`${urlPath}: meta description below hard floor (${description.length} < ${minDescriptionLength})`);
      } else {
        failures.push(`${urlPath}: meta description too short (${description.length} < ${minDescriptionLength})`);
      }
    } else if (description.length < 120 || description.length > 160) {
      warnings.push(`${urlPath}: meta description outside target range (${description.length}, target 120-160)`);
    }

    if (!title) {
      failures.push(`${urlPath}: missing title tag`);
    } else if (title.length < minTitleLength) {
      if (isBlogPost) {
        warnings.push(`${urlPath}: title below hard floor (${title.length} < ${minTitleLength})`);
      } else {
        failures.push(`${urlPath}: title too short (${title.length} < ${minTitleLength})`);
      }
    } else if (title.length < 30 || title.length > 60) {
      warnings.push(`${urlPath}: title outside target range (${title.length}, target 30-60)`);
    }

    if (description && (includePostsInDupScan || !isBlogPost)) {
      const existing = descriptions.get(description) || new Set();
      existing.add(urlPath);
      descriptions.set(description, existing);
    }
  }

  for (const [description, urlSet] of descriptions.entries()) {
    const urls = [...urlSet].sort((a, b) => a.localeCompare(b));
    if (urls.length > maxDuplicatePages) {
      const preview =
        description.length > 100 ? `${description.slice(0, 97).trim()}…` : description;
      const msg = [
        `Duplicate meta description: ${urls.length} URLs share the same string (audit limit is ${maxDuplicatePages} page(s) per description).`,
        `  Fix: add a unique \`description\` in each page's front matter (see _layouts/default.html).`,
        `  Preview: ${preview}`,
        `  URLs:`,
        ...urls.map((u) => `    - ${u}`),
      ].join('\n');
      if (dupSeverity === 'warn') {
        warnings.push(msg);
      } else {
        failures.push(msg);
      }
    }
  }

  console.log(`Checked ${checked.length} core SEO pages in ${siteDir}.`);

  for (const warning of warnings) {
    if (warning.includes('\n')) {
      console.log('WARNING:\n' + warning);
    } else {
      console.log(`WARNING: ${warning}`);
    }
  }

  if (failures.length > 0) {
    console.error('SEO audit failed:');
    for (const failure of failures) {
      if (failure.includes('\n')) {
        console.error(failure);
      } else {
        console.error(`- ${failure}`);
      }
    }
    process.exit(1);
  }

  console.log('SEO audit passed.');
}

run().catch((error) => {
  console.error(`SEO audit script failed: ${error.message}`);
  process.exit(1);
});
