---
layout: post
title: TDD and the Python Shebang
date: 2009-02-28 00:00:00.000000000 +11:00
updated_at: 2025-12-18 00:00:00 +11:00
---

Before I joined my current employer about two years ago I had heard of both
[Python][python] and [TDD][tdd] but used
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
reading [Ron Jeffries'][xpro] bowling game examples,
first the [C# object-oriented
example][bowling-oo] and then
[procedural][bowling-proc]
version.


[My first post of 2009]({% post_url 2009-01-01-tdd-in-vim %}) was on
doing TDD in Python using [Vim][vim]. Unfortunately, not all of
the Python code owned by ${PETES_EMPLOYER} was written using the same editor or
coding standards. I love the fact that Python uses indentation to determine code
blocks and has no need for ugly braces everywhere but it doesn't do anything to
enforce discipline in this area. Occasionally, when working with Other People's
Code, I've encountered problems where a mixture of indentation styles have been
employed and Python hasn't behaved. Recently I discovered that Python can throw
an error when this happens by supplying the switch '-tt' to the interpreter.
This is why all Python code that I write now begins with the following
[shebang][shebang] line...

```python
#!/usr/bin/env python -tt -Wall
```

I hope that is of some use to somebody.

[python]: https://www.python.org/
[tdd]: https://en.wikipedia.org/wiki/Test-driven_development
[xpro]: https://ronjeffries.com/
[bowling-oo]: https://ronjeffries.com/xprog/articles/acsbowling/
[bowling-proc]: https://ronjeffries.com/xprog/articles/acsbowlingproceduralframescore/
[vim]: https://www.vim.org/
[shebang]: https://en.wikipedia.org/wiki/Shebang_(Unix)

