# Migrating Utility Images to Local Assets

This guide explains how to download utility screenshots from microsites and store them locally with WebP optimization.

## Process

### 1. Download Screenshots from Microsites

```bash
# Create a script or manually download each image
# Example for Foretoken:
curl -o assets/images/utilities/foretoken.png https://www.johnsy.com/foretoken/og-image.png

# For all utilities:
curl -o assets/images/utilities/eventuate.png https://www.johnsy.com/eventuate/images/eventuate-social-preview.png
curl -o assets/images/utilities/crashcourse.png https://www.johnsy.com/crashcourse/og-image-with-course.png
curl -o assets/images/utilities/userscripts.png https://www.johnsy.com/tampermonkey-parkrun/images/alphabet-challenge.png
curl -o assets/images/utilities/ambassy.png https://www.johnsy.com/ambassy/ambassy-social-preview.png

# Microsites:
curl -o assets/images/utilities/qrty.png https://www.johnsy.com/QRTY/qr-code.png
curl -o assets/images/utilities/countdown.png https://www.johnsy.com/countdown/og-image.png
curl -o assets/images/utilities/progression.png https://www.johnsy.com/progression/assets/screenshot.png
curl -o assets/images/utilities/speedtest-analysis.png https://www.johnsy.com/speedtest-analysis/screenshot.png
```


### 2. Convert and Resize to WebP (1x and 2x)

The fetch-utility-images.mjs script now generates two WebP images for each utility:

- 1x: `/assets/images/webp/[id].webp` (289x152)
- 2x: `/assets/images/webp/[id]@2x.webp` (578x304)

This ensures optimal performance and crisp display on retina screens.

```bash
# Fetch, resize, and convert all utility images (1x and 2x)
pnpm run fetch:utility-images
```

### 3. Update Data Files


No changes are needed to YAML for webp images; the card partial auto-generates the correct paths for 1x and 2x.
## Responsive Usage in Templates

The utility card partial now uses `srcset` for responsive images:

```html
<picture>
  <source 
    srcset="/assets/images/webp/[id].webp 1x, /assets/images/webp/[id]@2x.webp 2x"
    type="image/webp"
  />
  <img 
    src="/assets/images/webp/[id].webp"
    srcset="/assets/images/webp/[id].webp 1x, /assets/images/webp/[id]@2x.webp 2x"
    width="289" height="152"
    alt="..."
    class="utility-preview"
    loading="lazy"
  />
</picture>
```

**Display size:** The card always displays images at 289x152px. The 2x image ensures sharpness on retina screens.

## Benefits of Local Assets

1. **Full Control**: No dependency on external microsite hosting
2. **Performance**: Serve from same domain (no DNS lookup, connection setup)
3. **Consistency**: Same caching strategy as other site assets
4. **Reliability**: No risk of external images breaking or changing
5. **Optimization**: Can control exact size, quality, and format

## Build Integration

Add to your build process (e.g., in Rakefile or CI/CD):

```ruby
# In Rakefile
task :build => [:images, :jekyll]

task :images do
  sh "pnpm run build:images:all"
end
```

## Keeping Images Updated


When you update a microsite's screenshot:

1. Download the new image to `assets/images/utilities/`
2. Run `pnpm run fetch:utility-images` (generates both 1x and 2x webp)
3. Commit the generated WebP images
4. Deploy

The script automatically detects when source images are newer than WebP versions and reconverts them.
