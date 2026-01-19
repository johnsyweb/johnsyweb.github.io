#!/usr/bin/env node

/**
 * Convert images to WebP format for optimal web delivery
 * 
 * Strategy:
 *   - Blog post images (images/): WebP stored side-by-side with originals
 *   - Utility screenshots (assets/images/utilities/): WebP stored in assets/images/webp/
 * 
 * Usage:
 *   node scripts/convert-to-webp.mjs [source-dir|all] [quality]
 * 
 * Examples:
 *   node scripts/convert-to-webp.mjs                          # Convert blog images (side-by-side)
 *   node scripts/convert-to-webp.mjs images 85                # Convert blog images at quality 85
 *   node scripts/convert-to-webp.mjs assets/images/utilities  # Convert utility images (centralized)
 *   node scripts/convert-to-webp.mjs all 90                   # Convert all images at quality 90
 */

import { spawn } from 'child_process';
import { readdir, stat, mkdir } from 'fs/promises';
import { join, dirname, basename, extname, relative } from 'path';
import { fileURLToPath } from 'url';
import { existsSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ROOT = join(__dirname, '..');

// Configuration
const DEFAULT_QUALITY = 85;
const SUPPORTED_FORMATS = ['.jpg', '.jpeg', '.png'];
const WEBP_OUTPUT_DIR = 'assets/images/webp'; // For utility/microsite images

// Directories that should have WebP versions side-by-side
const SIDE_BY_SIDE_DIRS = ['images'];

// Directories that should output to centralized webp folder
const CENTRALIZED_DIRS = ['assets/images/utilities'];

// Parse command line arguments
const sourceArg = process.argv[2];
const quality = parseInt(process.argv[3]) || DEFAULT_QUALITY;

// Determine processing mode and source directories
let sideBySideMode = true;
let sourceDirs = [];

if (sourceArg === 'all') {
  sourceDirs = [...SIDE_BY_SIDE_DIRS, ...CENTRALIZED_DIRS];
} else if (sourceArg) {
  // Check if provided directory should use side-by-side or centralized
  sideBySideMode = SIDE_BY_SIDE_DIRS.includes(sourceArg);
  sourceDirs = [sourceArg];
} else {
  // Default: process blog images side-by-side
  sourceDirs = SIDE_BY_SIDE_DIRS;
}

// Check if cwebp is installed
async function checkCwebpInstalled() {
  return new Promise((resolve) => {
    const check = spawn('which', ['cwebp']);
    check.on('close', (code) => {
      resolve(code === 0);
    });
  });
}

// Convert a single image to WebP
async function convertToWebP(sourcePath, outputPath, quality) {
  return new Promise((resolve, reject) => {
    const args = [
      sourcePath,
      '-q', quality.toString(),
      '-o', outputPath
    ];

    console.log(`Converting: ${relative(ROOT, sourcePath)} -> ${relative(ROOT, outputPath)}`);
    
    const convert = spawn('cwebp', args);
    
    convert.stderr.on('data', (data) => {
      // cwebp outputs progress to stderr, which is normal
      // Only log if it looks like an error
      const output = data.toString();
      if (output.includes('Error') || output.includes('error')) {
        console.error(output);
      }
    });
    
    convert.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`cwebp exited with code ${code} for ${sourcePath}`));
      }
    });
  });
}

// Recursively find all images in a directory
async function findImages(dir, images = []) {
  const entries = await readdir(dir);
  
  for (const entry of entries) {
    const fullPath = join(dir, entry);
    const stats = await stat(fullPath);
    
    if (stats.isDirectory()) {
      // Skip the webp output directory
      if (fullPath.includes(WEBP_OUTPUT_DIR)) {
        continue;
      }
      await findImages(fullPath, images);
    } else {
      const ext = extname(entry).toLowerCase();
      if (SUPPORTED_FORMATS.includes(ext)) {
        images.push(fullPath);
      }
    }
  }
  
  return images;
}

// Get WebP output path for a source image
function getWebPPath(sourcePath) {
  const relativePath = relative(ROOT, sourcePath);
  const dirName = dirname(sourcePath);
  const baseName = basename(sourcePath, extname(sourcePath));
  
  // Check if this directory should use side-by-side storage
  const useSideBySide = SIDE_BY_SIDE_DIRS.some(dir => 
    relativePath.startsWith(dir + '/')
  );
  
  if (useSideBySide) {
    // Store WebP next to the original image
    return join(dirName, `${baseName}.webp`);
  } else {
    // Store in centralized webp folder
    return join(ROOT, WEBP_OUTPUT_DIR, `${baseName}.webp`);
  }
}

// Main conversion process
async function convertImages() {
  console.log('🖼️  WebP Image Converter\n');
  
  // Check if cwebp is installed
  const hasWebP = await checkCwebpInstalled();
  if (!hasWebP) {
    console.error('❌ Error: cwebp is not installed.');
    console.error('\nInstall it with:');
    console.error('  macOS:   brew install webp');
    console.error('  Ubuntu:  apt-get install webp');
    console.error('  Windows: Download from https://developers.google.com/speed/webp/download\n');
    process.exit(1);
  }
  
  // Ensure output directory exists for centralized storage
  const webpDir = join(ROOT, WEBP_OUTPUT_DIR);
  const needsCentralizedDir = sourceDirs.some(dir => 
    CENTRALIZED_DIRS.includes(dir)
  );
  
  if (needsCentralizedDir && !existsSync(webpDir)) {
    await mkdir(webpDir, { recursive: true });
    console.log(`✅ Created output directory: ${WEBP_OUTPUT_DIR}\n`);
  }
  
  // Find all images
  const allImages = [];
  for (const sourceDir of sourceDirs) {
    const fullPath = join(ROOT, sourceDir);
    if (existsSync(fullPath)) {
      console.log(`📁 Scanning: ${sourceDir}`);
      const images = await findImages(fullPath);
      allImages.push(...images);
    } else {
      console.warn(`⚠️  Warning: Directory not found: ${sourceDir}`);
    }
  }
  
  console.log(`\n📊 Found ${allImages.length} images to convert`);
  console.log(`⚙️  Quality setting: ${quality}\n`);
  
  if (allImages.length === 0) {
    console.log('No images found to convert.');
    return;
  }
  
  // Convert images
  let converted = 0;
  let skipped = 0;
  let failed = 0;
  
  for (const imagePath of allImages) {
    const webpPath = getWebPPath(imagePath);
    
    // Check if WebP version already exists and is newer
    if (existsSync(webpPath)) {
      const sourceStats = await stat(imagePath);
      const webpStats = await stat(webpPath);
      
      if (webpStats.mtime > sourceStats.mtime) {
        skipped++;
        continue;
      }
    }
    
    try {
      await convertToWebP(imagePath, webpPath, quality);
      converted++;
    } catch (error) {
      console.error(`❌ Failed: ${error.message}`);
      failed++;
    }
  }
  
  console.log('\n' + '='.repeat(60));
  console.log('✨ Conversion complete!');
  console.log(`   Converted: ${converted}`);
  console.log(`   Skipped:   ${skipped} (up to date)`);
  if (failed > 0) {
    console.log(`   Failed:    ${failed}`);
  }
  console.log('='.repeat(60));
}

// Run the converter
convertImages().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
