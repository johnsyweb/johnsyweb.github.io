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

### 2. Convert to WebP

```bash
# Convert all utility images
pnpm run build:images:utilities

# Or manually
node scripts/convert-to-webp.mjs assets/images/utilities 85
```

### 3. Update Data Files

Update the `image` and `image_webp` paths in your YAML files:

```yaml
# Before (external URLs)
- id: foretoken
  image: https://www.johnsy.com/foretoken/og-image.png
  image_webp: https://www.johnsy.com/foretoken/og-image.webp

# After (local assets)
- id: foretoken
  image: /assets/images/utilities/foretoken.png
  image_webp: /assets/images/webp/foretoken.webp
```

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
2. Run `pnpm run build:images:utilities`
3. Commit both the PNG and generated WebP
4. Deploy

The script automatically detects when source images are newer than WebP versions and reconverts them.
