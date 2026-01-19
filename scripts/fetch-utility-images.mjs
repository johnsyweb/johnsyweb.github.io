#!/usr/bin/env node

/**
 * Fetch utility and microsite screenshots from external URLs
 * Downloads images from microsites and converts to WebP
 * 
 * Reads URLs from:
 *   - _data/parkrun-utilities.yml
 *   - _data/microsites.yml
 * 
 * Usage:
 *   node scripts/fetch-utility-images.mjs [--force]
 * 
 * Options:
 *   --force  Re-download even if local file exists
 */

import { readFile, writeFile, stat, mkdir, unlink } from 'fs/promises';
import { join, dirname, basename, extname } from 'path';
import { fileURLToPath } from 'url';
import { existsSync } from 'fs';
import { spawn } from 'child_process';
import https from 'https';
import http from 'http';
import yaml from 'yaml';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ROOT = join(__dirname, '..');

const OUTPUT_DIR = 'assets/images/utilities';
const WEBP_DIR = 'assets/images/webp';
const KEEP_ORIGINALS = false; // Delete PNGs after WebP conversion
const FORCE_DOWNLOAD = process.argv.includes('--force');

// Download a file from a URL
async function downloadFile(url, outputPath) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;
    
    const request = protocol.get(url, (response) => {
      if (response.statusCode === 302 || response.statusCode === 301) {
        // Handle redirects
        downloadFile(response.headers.location, outputPath)
          .then(resolve)
          .catch(reject);
        return;
      }
      
      if (response.statusCode !== 200) {
        reject(new Error(`HTTP ${response.statusCode}: ${url}`));
        return;
      }
      
      const chunks = [];
      response.on('data', (chunk) => chunks.push(chunk));
      response.on('end', async () => {
        try {
          const buffer = Buffer.concat(chunks);
          await writeFile(outputPath, buffer);
          resolve();
        } catch (error) {
          reject(error);
        }
      });
      response.on('error', reject);
    });
    
    request.on('error', reject);
    request.setTimeout(30000, () => {
      request.destroy();
      reject(new Error(`Timeout downloading: ${url}`));
    });
  });
}

// Convert image to WebP
async function convertToWebP(sourcePath, outputPath, quality = 85) {
  return new Promise((resolve, reject) => {
    const args = [sourcePath, '-q', quality.toString(), '-o', outputPath];
    const convert = spawn('cwebp', args);
    
    convert.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`cwebp exited with code ${code}`));
      }
    });
    
    convert.on('error', (error) => {
      reject(new Error(`Failed to run cwebp: ${error.message}`));
    });
  });
}

// Check if cwebp is installed
async function checkCwebpInstalled() {
  return new Promise((resolve) => {
    const check = spawn('which', ['cwebp']);
    check.on('close', (code) => resolve(code === 0));
  });
}

// Extract image URLs from YAML data
function extractImageUrls(data, collection) {
  const urls = [];
  const items = data[collection] || [];
  
  for (const item of items) {
    if (item.image && item.image.startsWith('http')) {
      urls.push({
        id: item.id,
        url: item.image,
        collection
      });
    }
  }
  
  return urls;
}

// Generate local filename from ID and URL
function getLocalFilename(id, url) {
  const ext = extname(url) || '.png';
  return `${id}${ext}`;
}

// Main process
async function fetchImages() {
  console.log('📸 Utility Image Fetcher\n');
  
  // Check if cwebp is installed
  const hasWebP = await checkCwebpInstalled();
  if (!hasWebP) {
    console.error('❌ Error: cwebp is not installed.');
    console.error('\nInstall it with:');
    console.error('  macOS:   brew install webp');
    console.error('  Ubuntu:  apt-get install webp\n');
    process.exit(1);
  }
  
  // Ensure output directories exist
  const outputDir = join(ROOT, OUTPUT_DIR);
  const webpDir = join(ROOT, WEBP_DIR);
  
  for (const dir of [outputDir, webpDir]) {
    if (!existsSync(dir)) {
      await mkdir(dir, { recursive: true });
      console.log(`✅ Created directory: ${dir.replace(ROOT + '/', '')}`);
    }
  }
  
  // Read YAML files
  const yamlFiles = [
    { path: '_data/parkrun-utilities.yml', collection: 'utilities' },
    { path: '_data/microsites.yml', collection: 'microsites' }
  ];
  
  const allUrls = [];
  
  for (const { path, collection } of yamlFiles) {
    try {
      const content = await readFile(join(ROOT, path), 'utf8');
      const data = yaml.parse(content);
      const urls = extractImageUrls(data, collection);
      allUrls.push(...urls);
      console.log(`📄 Found ${urls.length} images in ${path}`);
    } catch (error) {
      console.error(`⚠️  Warning: Could not read ${path}: ${error.message}`);
    }
  }
  
  console.log(`\n📊 Total images to process: ${allUrls.length}\n`);
  
  if (allUrls.length === 0) {
    console.log('No external image URLs found.');
    return;
  }
  
  let downloaded = 0;
  let skipped = 0;
  let converted = 0;
  let deleted = 0;
  let failed = 0;
  
  for (const { id, url, collection } of allUrls) {
    const filename = getLocalFilename(id, url);
    const localPath = join(outputDir, filename);
    const webpPath = join(webpDir, `${id}.webp`);
    const relativeLocal = join(OUTPUT_DIR, filename);
    const relativeWebP = join(WEBP_DIR, `${id}.webp`);
    
    try {
      // Download original image
      if (!existsSync(localPath) || FORCE_DOWNLOAD) {
        process.stdout.write(`⬇️  Downloading: ${id}... `);
        await downloadFile(url, localPath);
        console.log('✓');
        downloaded++;
      } else {
        console.log(`⏭️  Skipped: ${id} (already exists)`);
        skipped++;
      }
      
      // Convert to WebP
      if (!existsSync(webpPath) || FORCE_DOWNLOAD || downloaded > 0) {
        const sourceStats = await stat(localPath);
        let needsConversion = true;
        
        if (existsSync(webpPath) && !FORCE_DOWNLOAD) {
          const webpStats = await stat(webpPath);
          needsConversion = sourceStats.mtime > webpStats.mtime;
        }
        
        if (needsConversion) {
          process.stdout.write(`🔄 Converting: ${id} to WebP... `);
          await convertToWebP(localPath, webpPath);
          console.log('✓');
          converted++;
          
          // Delete original PNG/JPG after successful conversion
          if (!KEEP_ORIGINALS) {
            await unlink(localPath);
            deleted++;
          }
        }
      }
      
    } catch (error) {
      console.error(`❌ Failed: ${id} - ${error.message}`);
      failed++;
    }
  }
  
  console.log('\n' + '='.repeat(60));
  console.log('✨ Process complete!');
  console.log(`   Downloaded:   ${downloaded}`);
  console.log(`   Skipped:      ${skipped} (already exist)`);
  console.log(`   Converted:    ${converted}`);
  if (!KEEP_ORIGINALS && deleted > 0) {
    console.log(`   Cleaned up:   ${deleted} (originals deleted)`);
  }
  if (failed > 0) {
    console.log(`   Failed:       ${failed}`);
  }
  console.log('='.repeat(60));
  
  if (downloaded > 0 || converted > 0) {
    console.log('\n💡 Next steps:');
    console.log('   1. Commit the WebP images in assets/images/webp/');
    console.log('   2. YAML files auto-generate WebP paths from utility IDs');
    console.log('      Just use: image: [external-url]');
    console.log('      WebP path will be: /assets/images/webp/[id].webp');
  }
}

// Run the fetcher
fetchImages().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
