---
layout: default
title: 
og_image: /images/banner-og-compressed.jpg
og_image_alt: Rainbow Lego minifigures against a colourful brick wall
---

{% include schema-organization.html %}

Congratulations! You have successfully found the front page of my website. Take
ten points. I don't know what you thought you might find when you got here, but
this is about it. Unless of course you count the stuff that can be found by
following any of the links on this page. You are smart enough to figure that out
without me telling you, though.

Here is a collection of utitilies I've built for myself, which I share here for others to use and enjoy.

<div class="utility-grid">
  {% for microsite in site.data.microsites.microsites %}
    {% include utility-card.html card=microsite %}
  {% endfor %}
</div>

If you didn't find what you were looking for then I'm sorry. You could always 
[drop me a line](/contact) and then I can tell you why you didn't
find what you were looking for and when (if ever) you can expect to see it on
this site.

You look great today, incidentally.
