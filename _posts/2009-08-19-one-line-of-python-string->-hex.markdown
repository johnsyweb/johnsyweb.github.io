---
layout: post
title: 'One-line of Python: string -> hex'
---




Just a little something that may come in handy in the future (for my reference,
rather than yours), a Python one-liner for converting an ASCII string to
hexadecimal pairs.


```python
to_hex = lambda s: ' '.join(['%02X' % ord(ch) for ch in s])
```


As you were...



