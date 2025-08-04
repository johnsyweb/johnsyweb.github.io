---
layout: post
title: On Textpattern, Apache and Git
---



This weekend I've re-started on a website that I was meant to have finished ages
ago. Now that I have all of those extra minutes per day having [extracted myself
from Facebook's clutches](/blog/2008/12/27/facebook-no-more/), I've resolved to get
it finished and get it finished I shall.


Rather than re-inventing wheels, like I did with my own website, I've opted to
build this site using [Textpattern](https://textpattern.com/). So far it seems
pretty straightforward. This is ideal as I don't intend to maintain the new
website (another good reason not to hand-crafting my own Perl, PHP or Python).


One thing that did take a while to get working, however, is getting 'Clean
URLs', those without question marks and ampersands all over the place, to work.
Thankfully like so many things, [this is a solved
problem](https://textpattern.com/faq/66/404-error-when-linking-to-article-pages).
For future reference, the solution was easy for the virtual host on my MacBook
Pro, with just one AllowOverride line needed in
`/private/etc/apache2/extra/httpd-vhosts.conf`...


{% highlight apacheconf %}
<Directory "/path/to/website">
    Order Deny,Allow 
    Allow from all 
    AllowOverride FileInfo
</Directory>
{% endhighlight %}


Incidentally, I'm keeping both `/path/to/website` and `/private/etc/apache2`
under source control with [Git](https://git-scm.com/), as I am doing with pretty
much everything I do these days. Git is version control done correctly. Thank
you, [Linus](https://en.wikipedia.org/wiki/Linus_Torvalds)!

