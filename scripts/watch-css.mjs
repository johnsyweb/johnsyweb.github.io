#!/usr/bin/env node
import { watch } from 'fs';
import { execSync } from 'child_process';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = join(__dirname, '..');

const cssFiles = [
  'assets/css/style.css',
  'assets/css/colors-light.css',
  'assets/css/colors-dark.css'
];

const minifyCSS = (file) => {
  const minFile = file.replace('.css', '.min.css');
  try {
    execSync(`pnpm exec cleancss -O2 --inline=none -o ${minFile} ${file}`, {
      cwd: projectRoot,
      stdio: 'inherit'
    });
    console.log(`✓ Minified ${file} → ${minFile}`);
  } catch (error) {
    console.error(`✗ Failed to minify ${file}:`, error.message);
  }
};

console.log('👀 Watching CSS files for changes...');

cssFiles.forEach((file) => {
  const fullPath = join(projectRoot, file);
  
  // Initial minification
  minifyCSS(file);
  
  // Watch for changes
  watch(fullPath, (eventType) => {
    if (eventType === 'change') {
      console.log(`📝 ${file} changed, minifying...`);
      minifyCSS(file);
    }
  });
  
  console.log(`  Watching: ${file}`);
});

console.log('\nPress Ctrl+C to stop watching\n');
