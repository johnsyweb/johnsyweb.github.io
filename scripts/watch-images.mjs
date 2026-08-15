#!/usr/bin/env node

import { watch } from 'fs';
import { spawn } from 'child_process';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { resolveWatchDirs } from './lib/image-watch-dirs.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ROOT = join(__dirname, '..');

const IMAGE_EXTENSIONS = new Set(['.jpg', '.jpeg', '.png']);

let timer = null;
let running = false;
let rerunRequested = false;

function shouldHandle(filename) {
  if (!filename) return false;
  const lower = filename.toLowerCase();
  return Array.from(IMAGE_EXTENSIONS).some((ext) => lower.endsWith(ext));
}

function runConvertAll() {
  if (running) {
    rerunRequested = true;
    return;
  }

  running = true;
  console.log('Image change detected; updating WebP assets...');

  const child = spawn('node', ['scripts/convert-to-webp.mjs', 'all'], {
    cwd: ROOT,
    stdio: 'inherit'
  });

  child.on('close', () => {
    running = false;
    if (rerunRequested) {
      rerunRequested = false;
      runConvertAll();
    }
  });
}

function scheduleConvert() {
  if (timer) clearTimeout(timer);
  timer = setTimeout(runConvertAll, 300);
}

const watchDirs = resolveWatchDirs(ROOT);

console.log('Watching image directories for WebP conversion:');
for (const { dir, fullPath } of watchDirs) {
  console.log(`  - ${dir}`);
  watch(fullPath, { recursive: true }, (_eventType, filename) => {
    if (shouldHandle(filename)) {
      scheduleConvert();
    }
  });
}
