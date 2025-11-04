---
layout: post
categories:
  - accessibility
  - allyship
title: Switching to Atkinson Hyperlegible
date: 2025-11-04 01:50:00
---

I've updated this website to use [Atkinson Hyperlegible][atkinson-hyperlegible] as the default typeface, with [Atkinson Hyperlegible Mono][atkinson-hyperlegible] for code blocks. This change was inspired by reading the most recent [Better Allies newsletter][better-allies-oct-31-2025], which highlighted this free typeface from the Braille Institute.

As I've [mentioned before][pronouns-iation], I get a lot of value from the [Better Allies newsletter][better-allies-website]. Each week, Karen Catlin shares five actionable tips on inclusion, and I've learned a great deal from it. The newsletter's [October 31, 2025 edition][better-allies-oct-31-2025] included a section on using hyperlegible fonts, which caught my attention.

Atkinson Hyperlegible is specifically designed to increase character recognition, which improves readability for low-vision readers. The font is named after Braille Institute founder J. Robert Atkinson and is completely free to use.

![Side-by-side comparison of the About page showing Verdana font on the left and Atkinson Hyperlegible font on the right. The comparison demonstrates the improved character distinction and readability of the hyperlegible font.][font-comparison-image]{:.responsive-img title="About page before and after font change: Verdana vs Atkinson Hyperlegible"}

[The change][font-commit] was straightforward to implement. I added the Google Fonts links for both the regular and monospace variants, updated the font-family declarations in the CSS, and adjusted the font sizes slightly (from 13px to 15px) to maintain good readability given that Atkinson Hyperlegible is more condensed than the previous Verdana font. I also increased the heading sizes proportionally to maintain the visual hierarchy.

Sometimes the smallest changes can make a big difference in accessibility. Using a hyperlegible font is a simple way to make content more accessible to low-vision readers, and it can be something that benefits everyone.

<!-- Links -->

[pronouns-iation]: {% post_url 2022-11-13-pronouns-iation %}
[atkinson-hyperlegible]: https://brailleinstitute.org/freefont
[better-allies-website]: https://betterallies.com/more-content/
[better-allies-oct-31-2025]: https://us19.campaign-archive.com/?u=cc808df089bf312fc1a37916d&id=01c442ba79
[font-commit]: https://github.com/johnsyweb/johnsyweb.github.io/commit/b10ca51
[font-comparison-image]: /images/2025-11-04-about-page-font-comparison.jpg
