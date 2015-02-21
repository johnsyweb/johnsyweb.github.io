---
layout: post
title: TDD and the Python Shebang
---

Before I joined my current employer about two years ago I had heard of both
[Python](http://www.python.org/) and [TDD](http://en.wikipedia.org/wiki/Test-driven_development) but used
neither. Now Python is the first language I reach for whenever I want to write a
utility and I naturally start by writing a failing unit test. It's a fun way in
which to program, but more than that... Today I was telling a friend (and former
colleague) why I prefer test-driven development as a way of writing code. Here
are some of the reasons I enumerated:

- TDD helps me think.
- TDD helps me design.
- TDD helps me create clean interfaces.
- TDD helps me focus on developing just what needs to be developed.
- TDD helps me clean up my code.
- TDD tells me that my code does exactly what it is supposed to.
- TDD lets me test my code as often as I like at the press of a single key.

That last point is more an artefact of unit-testing, but is still valid.

If you're a programmer and you want to learn about TDD, you could do worse than
reading [Ron Jeffries'](http://www.xprogramming.com/) bowling game examples,
first the [C# object-oriented
example](http://www.xprogramming.com/xpmag/acsBowling.htm) and then
[procedural](http://www.xprogramming.com/xpmag/acsBowlingProcedural.htm)
version.


[My first post of 2009](/2009/01/01/tdd-in-vim/) was on
doing TDD in Python using [Vim](http://www.vim.org/). Unfortunately, not all of
the Python code owned by ${PETES_EMPLOYER} was written using the same editor or
coding standards. I love the fact that Python uses indentation to determine code
blocks and has no need for ugly braces everywhere but it doesn't do anything to
enforce discipline in this area. Occasionally, when working with Other People's
Code, I've encountered problems where a mixture of indentation styles have been
employed and Python hasn't behaved. Recently I discovered that Python can throw
an error when this happens by supplying the switch '-tt' to the interpreter.
This is why all Python code that I write now begins with the following
[shebang](http://en.wikipedia.org/wiki/Shebang_(Unix)) line...

{% highlight python %}
#!/usr/bin/env python -tt -Wall
{% endhighlight %}

I hope that is of some use to somebody.

