#!/usr/bin/env node
import { watch } from 'fs';
import { execSync } from 'child_process';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = join(__dirname, '..');

const jsFiles = [
  'assets/js/404.js',
  'assets/js/blog-entry-flash.js',
  'assets/js/mobile-menu.js',
  'assets/js/search.js',
  'blog-entry-sw.js'
];

const minifyJS = (file) => {
  const minFile = file.replace('.js', '.min.js');
  try {
    execSync(`pnpm exec terser ${file} --compress --mangle -o ${minFile}`, {
      cwd: projectRoot,
      stdio: 'inherit'
    });
    console.log(`✓ Minified ${file} → ${minFile}`);
  } catch (error) {
    console.error(`✗ Failed to minify ${file}:`, error.message);
  }
};

console.log('👀 Watching JavaScript files for changes...');

jsFiles.forEach((file) => {
  const fullPath = join(projectRoot, file);
  
  // Initial minification
  minifyJS(file);
  
  // Watch for changes
  watch(fullPath, (eventType) => {
    if (eventType === 'change') {
      console.log(`📝 ${file} changed, minifying...`);
      minifyJS(file);
    }
  });
  
  console.log(`  Watching: ${file}`);
});

console.log('\nPress Ctrl+C to stop watching\n');
