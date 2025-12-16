import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';
import { spawnSync } from 'child_process';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

function parseArgs(argv) {
  const out = {};
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      const [k, v] = a.includes('=') ? a.split('=') : [a, argv[i + 1]];
      const key = k.replace(/^--/, '');
      out[key] = v;
      if (!a.includes('=') && v && !v.startsWith('--')) i++;
    }
  }
  return out;
}

const args = parseArgs(process.argv);
const branchBase = args['branch-url'] || 'http://127.0.0.1:4100';
const mainBase = args['main-url'] || 'http://127.0.0.1:4101';
const outDir = path.resolve(args['out-dir'] || path.join(__dirname, '..', 'images'));
const tmpDir = path.resolve(args['tmp-dir'] || path.join(__dirname, '..', 'tmp'));
const outPrefix = args['out-prefix'] || 'comparison';
const pagesArg = (args['pages'] || '/about/').split(',').map(s => s.trim()).filter(Boolean);
const modes = [
  { name: 'light', colorScheme: 'light' },
  { name: 'dark', colorScheme: 'dark' },
];

fs.mkdirSync(outDir, { recursive: true });
fs.mkdirSync(tmpDir, { recursive: true });

function slugForPath(p) {
  if (p === '/' || p === '') return 'home';
  const cleaned = p.replace(/^\//, '').replace(/\/$/, '');
  return cleaned.replace(/\W+/g, '-') || 'page';
}

console.log('Output dir:', outDir);
console.log('Temp dir:', tmpDir);
console.log('Pages:', pagesArg.join(', '));

try {
  for (const mode of modes) {
    console.log(`\nMode: ${mode.name}`);
    const browser = await chromium.launch({ headless: true });
    const context = await browser.newContext({
      colorScheme: mode.colorScheme,
      viewport: { width: 1280, height: 720 },
    });
    const page = await context.newPage();

    for (const urlPath of pagesArg) {
      const slug = slugForPath(urlPath);
      const mainShot = path.join(tmpDir, `tmp-${slug}-${mode.name}-main.png`);
      const branchShot = path.join(tmpDir, `tmp-${slug}-${mode.name}-branch.png`);
      const combined = path.join(outDir, `${outPrefix}-${mode.name}.png`);

      console.log(`  Main:    ${mainBase}${urlPath}`);
      await page.goto(`${mainBase}${urlPath}`, { waitUntil: 'networkidle' });
      await page.screenshot({ path: mainShot, fullPage: true });

      console.log(`  Branch:  ${branchBase}${urlPath}`);
      await page.goto(`${branchBase}${urlPath}`, { waitUntil: 'networkidle' });
      await page.screenshot({ path: branchShot, fullPage: true });

      // Stitch using ImageMagick (prefer magick, fallback to convert)
      const candidates = ['magick', '/usr/local/bin/magick', '/opt/homebrew/bin/magick', '/usr/bin/magick', 'convert', '/usr/local/bin/convert', '/opt/homebrew/bin/convert', '/usr/bin/convert'];
      const bin = candidates.find(b => {
        try { return spawnSync(b, ['-version']).status === 0; } catch { return false; }
      });
      if (bin) {
        const args = [mainShot, branchShot, '+append', combined];
        const res = spawnSync(bin, args, { stdio: 'inherit' });
        if (res.status !== 0) {
          console.error('    Stitch failed');
        } else {
          console.log(`    Saved: ${combined}`);
        }
      } else {
        console.warn('    ImageMagick not found; leaving separate screenshots in tmp');
      }
    }
    await browser.close();
  }
  console.log('\nAll captures complete.');
} catch (err) {
  console.error('Error during capture:', err);
  process.exit(1);
}
