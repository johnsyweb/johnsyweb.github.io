#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates style test pages from CSS files to ensure they stay in sync
# This script extracts color definitions and generates comprehensive test HTML

require 'json'

CSS_DIR = 'assets/css'
OUTPUT_DIR = '_site'
LIGHT_CSS = "#{CSS_DIR}/colors-light.css"
DARK_CSS = "#{CSS_DIR}/colors-dark.css"
STYLE_CSS = "#{CSS_DIR}/style.css"

def extract_colors(css_file)
  return {} unless File.exist?(css_file)
  
  content = File.read(css_file)
  colors = {}
  
  # Extract color definitions from CSS
  content.scan(/^([^{]+)\{([^}]+)\}/m).each do |selector, rules|
    selector = selector.strip.gsub(/\s+/, ' ')
    
    # Extract colors from rules
    rules.scan(/(color|background-color|border-color):\s*(#[0-9a-fA-F]{6}|#[0-9a-fA-F]{3});/) do |property, value|
      colors[selector] ||= {}
      colors[selector][property] = value
    end
  end
  
  colors
end

def extract_style_properties(css_file)
  return {} unless File.exist?(css_file)
  
  content = File.read(css_file)
  styles = {}
  
  # Extract various style properties from CSS
  content.scan(/^([^{@]+)\{([^}]+)\}/m).each do |selector, rules|
    selector = selector.strip.gsub(/\s+/, ' ')
    styles[selector] ||= {}
    
    # Extract font properties
    rules.scan(/font-family:\s*([^;]+);/).each { |m| styles[selector]['font-family'] = m[0].strip.gsub(/\s+/, ' ') }
    rules.scan(/font-size:\s*([^;]+);/).each { |m| styles[selector]['font-size'] = m[0].strip }
    rules.scan(/font-weight:\s*([^;]+);/).each { |m| styles[selector]['font-weight'] = m[0].strip }
    rules.scan(/line-height:\s*([^;]+);/).each { |m| styles[selector]['line-height'] = m[0].strip }
    
    # Extract text properties
    rules.scan(/text-decoration:\s*([^;]+);/).each { |m| styles[selector]['text-decoration'] = m[0].strip }
    rules.scan(/border-bottom:\s*([^;]+);/).each { |m| styles[selector]['border-bottom'] = m[0].strip }
  end
  
  styles
end

def extract_selectors(css_file)
  return [] unless File.exist?(css_file)
  
  content = File.read(css_file)
  selectors = []
  
  # Find all CSS selectors
  content.scan(/^([^{@]+)\{/).each do |match|
    selector = match[0].strip
    next if selector.start_with?('@')
    selectors << selector unless selectors.include?(selector)
  end
  
  selectors
end

def describe_style(element, light_props, dark_props, style_props)
  description = []
  
  # Font family
  if style_props['font-family']
    font = style_props['font-family'].gsub(/["']/, '')
    description << "#{font} font"
  end
  
  # Font size
  if style_props['font-size']
    description << "#{style_props['font-size']}"
  end
  
  # Text color
  if light_props['color']
    description << "color: #{light_props['color']} (light)"
  end
  if dark_props['color']
    description << "#{dark_props['color']} (dark)"
  end
  
  # Background
  if light_props['background-color'] || dark_props['background-color']
    bg_light = light_props['background-color'] || '(inherited)'
    bg_dark = dark_props['background-color'] || '(inherited)'
    description << "background: #{bg_light} (light) / #{bg_dark} (dark)"
  end
  
  # Borders and decoration
  if style_props['border-bottom']
    description << "border-bottom: #{style_props['border-bottom']}"
  end
  if light_props['border-color']
    description << "border-color: #{light_props['border-color']} (light)"
  end
  if dark_props['border-color']
    description << "#{dark_props['border-color']} (dark)"
  end
  if style_props['text-decoration'] && style_props['text-decoration'] != 'none'
    description << "text-decoration: #{style_props['text-decoration']}"
  end
  
  description.join(', ')
end

def generate_markdown
  light_colors = extract_colors(LIGHT_CSS)
  dark_colors = extract_colors(DARK_CSS)
  style_props = extract_style_properties(STYLE_CSS)
  
  # Get body/html styles
  body_light = light_colors['html, body'] || {}
  body_dark = dark_colors['html, body'] || {}
  body_style = style_props['body'] || {}
  
  # Get heading styles
  h1_light = light_colors['h1, h2, h3'] || light_colors['h1'] || {}
  h1_dark = dark_colors['h1, h2, h3'] || dark_colors['h1'] || {}
  h1_style = style_props['h1'] || {}
  
  h2_style = style_props['h2'] || {}
  h3_style = style_props['h3'] || {}
  
  # Get link styles
  link_light = light_colors['a, a:visited, a:active'] || {}
  link_dark = dark_colors['a, a:visited, a:active'] || {}
  link_style = style_props['a, a:active, a:visited'] || {}
  
  link_hover_light = light_colors['a:hover'] || {}
  link_hover_dark = dark_colors['a:hover'] || {}
  
  # Get code styles
  code_style = style_props['code'] || {}
  
  # Get blockquote styles
  blockquote_light = light_colors['blockquote'] || {}
  blockquote_dark = dark_colors['blockquote'] || {}
  blockquote_style = style_props['blockquote'] || {}
  
  # Generate markdown with comprehensive examples
  markdown = <<~MARKDOWN
    ---
    layout: default
    title: Style Test Page
    description: Auto-generated comprehensive test page for all CSS styles
    pagefind_index: false
    ---
    
    <!-- This file is auto-generated by scripts/generate_style_test.rb -->
    <!-- Do not edit manually - changes will be overwritten -->
    
    # H1 Heading: Style Test Page
    
    <p><small>This h1 element uses #{describe_style('h1', h1_light, h1_dark, h1_style)}</small></p>
    
    This page exercises all CSS styles to ensure accessibility compliance. It is automatically generated from the CSS files.
    
    <p><small>Body text uses #{describe_style('body', body_light, body_dark, body_style)}</small></p>
    
    ## H2: Typography Hierarchy
    
    <p><small>This h2 element uses #{describe_style('h2', h1_light, h1_dark, h2_style)}</small></p>
    
    ### H3: Level 3 Heading
    
    <p><small>This h3 element uses #{describe_style('h3', h1_light, h1_dark, h3_style)}</small></p>
    
    Regular paragraph text with **bold text** (font-weight: #{style_props['strong, b']&.dig('font-weight') || '700'}), 
    *italic text* (font-style: #{style_props['em, i']&.dig('font-style') || 'italic'}), and ***bold italic text***. 
    This paragraph contains enough text to demonstrate line-height (#{body_style['line-height']}) and readability across multiple lines. 
    The quick brown fox jumps over the lazy dog.
    
    ## H2: Links and Interactive Elements
    
    Here is a [regular inline link](#) within body text. 
    
    <p><small>Links use #{describe_style('a', link_light, link_dark, link_style)}</small></p>
    
    <p><small>Link hover state: #{describe_style('a:hover', link_hover_light, link_hover_dark, {})}</small></p>
    
    Multiple links in a row: [Link One](#) | [Link Two](#) | [Link Three](#)
    
    A paragraph with [a link in the middle of text](#) and more text after it to show inline styling and contrast.
    
    ### H3: Links in Headings
    
    #### H4: [This is a linked heading](#)
    
    <p><small>Heading links: #{describe_style('h1 a', light_colors['h1 a, h1 a:visited, h1 a:active'] || {}, dark_colors['h1 a, h1 a:visited, h1 a:active'] || {}, {})}</small></p>
    
    ## H2: Lists
    
    ### H3: Unordered List
    
    - First list item with enough text to potentially wrap to multiple lines
    - Second list item
      - Nested list item  
      - Another nested item with [a link](#)
    - Third list item with **bold** and *italic* text
    - Fourth item
    
    <p><small>List style: #{style_props['ul']&.dig('list-style') || 'disc'}</small></p>
    
    ### H3: Ordered List
    
    1. First ordered item
    2. Second ordered item
       1. Nested ordered item
       2. Another nested item
    3. Third item with `inline code`
    4. Fourth item
    
    <p><small>Ordered list style: #{style_props['ol']&.dig('list-style') || 'bullet'}</small></p>
    
    ## H2: Code and Preformatted Text
    
    Inline code should be readable: `const example = "code snippet";` and `function test() { return true; }`
    
    <p><small>Inline code uses #{describe_style('code', {}, {}, code_style)}</small></p>
    
    Multiple inline codes: `var`, `let`, `const`, `function`, `class`, `import`, `export`
    
    ### H3: Code Blocks
    
    ```javascript
    // JavaScript example
    function calculateContrast(color1, color2) {
      const luminance1 = getRelativeLuminance(color1);
      const luminance2 = getRelativeLuminance(color2);
      const lighter = Math.max(luminance1, luminance2);
      const darker = Math.min(luminance1, luminance2);
      return (lighter + 0.05) / (darker + 0.05);
    }
    ```
    
    <p><small>Code blocks use syntax highlighting with colors defined in colors-light.css and colors-dark.css</small></p>
    
    ```python
    # Python example  
    def calculate_contrast(color1, color2):
        luminance1 = get_relative_luminance(color1)
        luminance2 = get_relative_luminance(color2)
        return (max(luminance1, luminance2) + 0.05) / (min(luminance1, luminance2) + 0.05)
    ```
    
    ## H2: Blockquotes
    
    > This is a blockquote that should be visually distinct from body text while maintaining readability. 
    > Blockquotes often contain longer passages that need sufficient contrast against the background.
    >
    > The border and text colors must meet WCAG standards.
    
    <p><small>Blockquotes use #{describe_style('blockquote', blockquote_light, blockquote_dark, blockquote_style)}</small></p>
    
    > A shorter blockquote with [a link inside](#).
    
    ## H2: Text Formatting and Special Elements
    
    Text with <abbr title="abbreviation">abbreviations</abbr> and <acronym title="Cascading Style Sheets">CSS</acronym> elements.
    
    Superscript: E = mc<sup>2</sup>, x<sup>n</sup>
    
    Subscript: H<sub>2</sub>O, CO<sub>2</sub>
    
    <small>Small text (font-size: #{style_props['small']&.dig('font-size') || '0.85em'}) should still meet contrast requirements</small>
    
    **Bold text**, *italic text*, ***bold italic text***
    
    ## H2: Tables
    
    | Header 1 | Header 2 | Header 3 | Header 4 |
    |----------|----------|----------|----------|
    | Cell 1   | Cell 2   | Cell 3   | Cell 4   |
    | Cell 5   | Cell 6   | Cell 7   | Cell 8   |
    | [Link](#)| **Bold** | *Italic* | `code`   |
    
    ## H2: Article Meta Information
    
    <div class="meta">
    Posted on 15 December 2025 by <em><acronym title="Peter Alexander Johns">paj</acronym></em>
    </div>
    
    <p><small>Meta information uses font-size: #{style_props['article .meta']&.dig('font-size') || '0.85em'}, font-style: italic</small></p>
    
    ## H2: Sidebar Navigation Simulation
    
    <div style="text-align: right; font-size: 1.2em; padding: 2px 4px;">
      <a href="/">Home</a><br>
      <a href="/about/">About</a><br>
      <a href="/blog/">Blog</a><br>
      <a href="/contact/">Contact</a>
    </div>
    
    <p><small>Sidebar links: font-size: 1.2em, #{describe_style('#sidebar a', light_colors['#sidebar a:hover'] || {}, dark_colors['#sidebar a:hover'] || {}, {})}</small></p>
    
    ## H2: Footer Content
    
    <div style="font-size: 0.85em; padding-top: 10px; border-top: 1px solid currentColor; margin-top: 20px;">
      <p>Copyright © 2000-2025 <a href="/about/"><em>paj</em></a>. All rights reserved.</p>
      <p>Footer text typically uses smaller font sizes and should still maintain accessibility standards.</p>
      <p>Hosted by <a href="https://github.com">GitHub</a>, powered by <a href="https://jekyllrb.com">Jekyll</a>.</p>
    </div>
    
    <p><small>Footer: font-size: 0.85em, #{describe_style('#footer', light_colors['#footer'] || {}, dark_colors['#footer'] || {}, {})}</small></p>
    
    ## H2: Skip Link
    
    <a href="#content" class="skip-link">Skip to main content</a>
    
    <p><small>Skip link is positioned off-screen until focused for keyboard navigation</small></p>
    
    ---
    
    ## CSS Properties Summary
    
    ### Light Mode Colors
    
  MARKDOWN
  
  # Add color info from extracted CSS
  light_colors.each do |selector, props|
    markdown += "\n**`#{selector}`**\n\n"
    props.each do |prop, value|
      markdown += "- #{prop}: <span style=\"display:inline-block;width:0.9em;height:0.9em;background:#{value};border:1px solid currentColor;vertical-align:middle;margin-right:0.3em\"></span><code>#{value}</code>\n"
    end
  end
  
  markdown += "\n### Dark Mode Colors\n\n"
  dark_colors.each do |selector, props|
    markdown += "\n**`#{selector}`**\n\n"
    props.each do |prop, value|
      markdown += "- #{prop}: <span style=\"display:inline-block;width:0.9em;height:0.9em;background:#{value};border:1px solid currentColor;vertical-align:middle;margin-right:0.3em\"></span><code>#{value}</code>\n"
    end
  end
  
  markdown += <<~FOOTER
    
    ---
    
    ## Accessibility Requirements
    
    All color and font combinations on this page must meet WCAG AA standards:
    
    - Normal text (< 18pt): ≥4.5:1 contrast ratio
    - Large text (≥ 18pt or ≥ 14pt bold): ≥3:1 contrast ratio
    - Interactive elements must be distinguishable
    - Focus indicators must be visible
    - Color should not be the only means of conveying information
    
    **Generated**: #{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S UTC')}  
    **Source**: `scripts/generate_style_test.rb`  
    **Build fails if**: Any element on this page does not meet WCAG AA accessibility standards
  FOOTER
  
  markdown
end

# Main execution
if __FILE__ == $0
  puts "Generating style test page from CSS files..."
  
  markdown = generate_markdown
  File.write('style-test.markdown', markdown)
  
  puts "✓ Generated style-test.markdown"
  puts "  - Light mode colors: #{extract_colors(LIGHT_CSS).size} selectors"
  puts "  - Dark mode colors: #{extract_colors(DARK_CSS).size} selectors"
end
