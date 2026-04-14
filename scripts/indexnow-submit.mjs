#!/usr/bin/env node
import { execSync } from 'child_process';
import { promises as fs } from 'fs';
import path from 'path';

const args = process.argv.slice(2);
const modeArg = args.find((arg) => arg.startsWith('--mode='));
const mode = modeArg ? modeArg.split('=')[1] : 'incremental';

const siteDir = process.env.SITE_DIR || '_site';
const siteUrl = (process.env.SITE_URL || 'https://www.johnsy.com').replace(/\/$/, '');
const key = process.env.INDEXNOW_KEY;
const beforeSha = process.env.GITHUB_EVENT_BEFORE;
const currentSha = process.env.GITHUB_SHA;

if (!key) {
  console.log('::warning::INDEXNOW_KEY not set, skipping IndexNow submission.');
  process.exit(0);
}

function normalizeUrl(url) {
  try {
    const parsed = new URL(url);
    if (parsed.host.includes('johnsy.com')) {
      parsed.protocol = 'https:';
      parsed.host = 'www.johnsy.com';
    }
    return parsed.toString();
  } catch {
    return url;
  }
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

function extractCanonical(html) {
  const match = html.match(/<link[^>]+rel=["']canonical["'][^>]+href=["']([^"']+)["'][^>]*>/i);
  return match ? match[1] : '';
}

async function collectSiteUrls() {
  const htmlFiles = await walkHtmlFiles(siteDir);
  const urls = new Set();

  for (const file of htmlFiles) {
    const html = await fs.readFile(file, 'utf8');
    const canonical = extractCanonical(html);
    if (canonical) {
      urls.add(normalizeUrl(canonical));
    }
  }

  return [...urls];
}

function mapPathToUrl(changedPath) {
  if (changedPath === 'index.markdown' || changedPath === 'index.md' || changedPath === 'index.html') {
    return `${siteUrl}/`;
  }

  if (changedPath === '404.md' || changedPath === '404.html') {
    return `${siteUrl}/404.html`;
  }

  const postMatch = changedPath.match(/^_posts\/(\d{4})-(\d{2})-(\d{2})-(.+)\.(markdown|md|html)$/);
  if (postMatch) {
    const [, year, month, day, slug] = postMatch;
    return `${siteUrl}/blog/${year}/${month}/${day}/${slug}/`;
  }

  const indexMatch = changedPath.match(/^(.+)\/index\.(markdown|md|html)$/);
  if (indexMatch) {
    return `${siteUrl}/${indexMatch[1]}/`;
  }

  return '';
}

function getChangedFiles() {
  if (!beforeSha || !currentSha || beforeSha === '0000000000000000000000000000000000000000') {
    return [];
  }

  try {
    const output = execSync(`git diff --name-only ${beforeSha} ${currentSha}`, { encoding: 'utf8' });
    return output
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean);
  } catch (error) {
    console.log(`::warning::Unable to compute changed files for IndexNow: ${error.message}`);
    return null;
  }
}

async function collectIncrementalUrls() {
  const changedFiles = getChangedFiles();
  if (changedFiles === null) {
    console.log('::warning::Falling back to full IndexNow submission because incremental diff could not be computed.');
    return collectSiteUrls();
  }

  if (changedFiles.length === 0) {
    return [];
  }

  const sharedTemplateChanged = changedFiles.some((file) =>
    file.startsWith('_layouts/') || file.startsWith('_includes/') || file === '_config.yml'
  );

  if (sharedTemplateChanged) {
    return collectSiteUrls();
  }

  const urls = new Set();
  for (const file of changedFiles) {
    const mapped = mapPathToUrl(file);
    if (mapped) {
      urls.add(normalizeUrl(mapped));
    }
  }

  return [...urls];
}

async function submitUrls(urls) {
  if (urls.length === 0) {
    console.log('No URLs to submit to IndexNow.');
    return;
  }

  const payload = {
    host: new URL(siteUrl).host,
    key,
    keyLocation: `${siteUrl}/${key}.txt`,
    urlList: urls,
  };

  const response = await fetch('https://api.indexnow.org/indexnow', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`IndexNow submission failed (${response.status}): ${text}`);
  }

  console.log(`Submitted ${urls.length} URL(s) to IndexNow.`);
}

async function run() {
  const urls = mode === 'full' ? await collectSiteUrls() : await collectIncrementalUrls();
  await submitUrls(urls);
}

run().catch((error) => {
  console.error(`IndexNow error: ${error.message}`);
  process.exit(1);
});
