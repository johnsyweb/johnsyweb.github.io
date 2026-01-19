# Image Optimization Setup

This site uses WebP images for optimal performance while maintaining fallbacks for compatibility.

## Two-Strategy Approach

### 1. Blog Post Images (Side-by-Side Storage)
- **Location**: `images/` directory
- **Strategy**: WebP versions stored next to originals
- **Example**: 
  - Original: `images/2019-01-21-password-entry.png`
  - WebP: `images/2019-01-21-password-entry.webp`

### 2. Utility/Microsite Screenshots (Centralized Storage)
- **Location**: WebP only in `assets/images/webp/`
- **Strategy**: Downloads from microsites, converts to WebP, deletes originals
- **Auto-generated paths**: WebP path determined from utility `id`
- **Example**:
  - Source: `https://www.johnsy.com/foretoken/og-image.png`
  - WebP: `assets/images/webp/foretoken.webp` (auto-generated from `id: foretoken`)

## Installation

Install the WebP conversion tool:

```bash
# macOS
brew install webp

# Ubuntu/Debian
apt-get install webp

# Windows
# Download from https://developers.google.com/speed/webp/download
```

## Usage

### Convert Images

```bash
# Convert blog post images (default, side-by-side)
pnpm run build:images

# Fetch utility screenshots from microsites and convert to WebP
pnpm run fetch:utility-images

# Update utility images (fetch + convert)
pnpm run update:utility-images

# Force re-download utility images
pnpm run fetch:utility-images:force

# Convert all blog images
pnpm run build:images:all
```

### Manual Conversion

```bash
# Blog images at quality 85
node scripts/convert-to-webp.mjs images 85

# Utility images at quality 90
node scripts/convert-to-webp.mjs assets/images/utilities 90

# All images at quality 85
node scripts/convert-to-webp.mjs all 85
```

## In Blog Posts

### Using the Responsive Image Include

```liquid
{% include responsive-image.html 
   src="/images/2019-01-21-password-entry.png" 
   alt="Password Entry Screen"
   title="1Password entry form"
   width="1200"
   height="800"
%}
```

**Benefits:**
- Automatically serves WebP to supported browsers
- Falls back to PNG/JPG for older browsers
- Includes width/height for better CLS scores
- Lazy loading by default

### Traditional Markdown (Still Works)

```markdown
![Password Entry](/images/2019-01-21-password-entry.png "1Password entry form")
```

This will serve the PNG/JPG. To get WebP benefits, use the include above.

## In Utility Cards

Utility cards automatically use the `<picture>` element with WebP support. **WebP paths are auto-generated from the utility ID**, so you don't need to specify them:

```yaml
# _data/parkrun-utilities.yml or _data/microsites.yml
- id: example
  title: Example Tool
  image: https://www.johnsy.com/example/og-image.png  # External URL
  image_width: 1200
  image_height: 630
  image_alt: "Example tool interface"
  image_title: "Screenshot of Example tool showing main features"
```

**Automatic behavior:**
- External images (starting with `http`): Fetched and converted to WebP by `fetch:utility-images` script
- WebP path auto-generated: `/assets/images/webp/example.webp` (from `id: example`)
- No need to manually specify `image_webp` field

## Performance Benefits

- **WebP Size Savings**: Typically 25-35% smaller than PNG/JPG
- **Faster Page Loads**: Smaller files = faster downloads
- **Better Core Web Vitals**: 
  - LCP (Largest Contentful Paint): Faster image loading
  - CLS (Cumulative Layout Shift): Width/height prevent layout shifts
- **SEO Benefits**: Page speed is a ranking factor

## Build Process Integration

**For blog images** (side-by-side WebP):
```bash
pnpm run build:images
```

**For utility screenshots** (automated fetch + convert):
```bash
pnpm run update:utility-images
```

The conversion scripts:
- Only convert images that have been modified (checks timestamps)
- Skip already up-to-date WebP versions
- Support configurable quality settings (default: 85)
- **Utility script**: Automatically deletes original PNGs after WebP conversion to save space

## Browser Support

WebP is supported by:
- Chrome 23+
- Firefox 65+
- Edge 18+
- Safari 14+ (macOS 11+, iOS 14+)
- Opera 12.1+

Older browsers automatically receive the PNG/JPG fallback via the `<picture>` element.
