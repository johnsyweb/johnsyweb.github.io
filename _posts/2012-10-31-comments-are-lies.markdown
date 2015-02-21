---
layout: post
title: Comments Are Lies!
---

I recently came across a blog entry on [Importance of Writing Code Comments in
Software
Development](http://technoladder.blogspot.com.au/2012/10/importance-of-writing-code-comments-in.html).
It's a proposition I've heard many times before, so I took a read to see if
there was some reasoning I may have missed. There wasn't.



Like the author of that article, I spend _far_ more time reading code than
writing it. _O tempora o mores_! Comments are not what I want to see, my
friends, _Clean Code_ is what I want to see!


[Robert C. "Uncle Bob" Martin](http://en.wikipedia.org/wiki/Robert_Cecil_Martin)
[(more than)](http://coding.derkeiler.com/Archive/General/comp.object/2004-06/0342.html)
once declared: [_Comments are lies_](http://agilepractices2010.blogspot.com.au/2010/06/solid-principles-of-object-oriented.html).
He is (partially) right!



Here is some code from a project at my workplace. I've changed some of the names
to protect the guilty but otherwise this is genuine:


{% highlight c++ %}
//  --------------------------------------------------------------------------
//  Method Name:        CProtocolField::setValue
//  Definition:         This method sets the value attribute of the CProtocolField.
//  Qualification:      none
//  Export:             public
//
//  Return:             void
//  Parameters:         double value
//
//  Preconditions:      none
//  Postconditions:     this->getString() == value
//  Exceptions:         none

void
CProtocolField::setValue(const string&amp; value)
{
myLength = value.length();
myValue = new char[myLength+1];
if (myValue != 0)
{
memcpy(myValue, value.c_str(), myLength);
}
myValue[myLength] = '\0';
myBuffer = NULL;
}
//  --------------------------------------------------------------------------
{% endhighlight %}


Ignore the terrible formatting, variable names and call to
`memcpy()`, Did you spot the _lies_?


The "Method Name" is quite correct but I didn't need a comment to tell me that.
I suspect that even if you've never seen C++ before, you'd be able to tell me
what the name of the `class` and its method are. The "Definition",
hardly needed a resident of 221B Baker Street to reveal it to the unsuspecting
public, it sets the value, hence its name. It also does some other things, but
we'll come to that later. "Qualification" is used (in case you were wondering)
to explain to the unseasoned reader whether a particular method is
`static` or `const` or even `virtual`. Given
this method is used to set a member variable (or three!), it's pretty obviously
nether of the first two. According to the declaration in the header-file, it's
non-`virtual` but... `CProtocolField` is derived from
`IProtocolField`, which declares `setValue(const
string&amp;)` as _pure `virtual`_, making
_this_ method `virtual`. A lie!



Helpfully we're told that this set-function has a `public` access
specifier. I'm not sure what use a private setter would be, but we'll move right
along to the blatant lie: "`Parameters:         double value`"! Why would
any programmer write that? This method clearly takes one argument and it's a
`const string&amp;`!



Of course a programmer _didn't_ waste their time writing this lie. It was
copied and pasted from the `double` overload 44 lines earlier in the
file. (I submitted a patch to remove the duplication, of course).



The "Preconditions" also lie. Whomever assumed responsibility for
allocating `myBuffer` (a raw `char*`, no less) also assumed
the precondition that this buffer has not already been allocated. This same
(incorrect) assumption is made in eight other places in the same source file!
Removing the memory leak was the main reason for me submitting a patch (shared
code ownership is a topic for another day).



The claim in "Postconditions" tells us nothing useful. What if I never call
`getString()`, what is the state of my object? If there were accompanying
unit-tests, I would have checked them. (Instead, I _wrote_ them).



Unit-tests are of course the best documentation for any code. They are living
documents that you can execute at any time.



I said that Uncle Bob was only &quot;partially&quot; right. The comments below
(from the same code-base) tell the truth, the whole truth and nothing but the
truth:


{% highlight c++ %}
//////////////////////////////////////////////////////////////////////////////
//
// Function Name:   ExcCxlCached::~ExcCxlCached()
//
// Definition:      Destructor for the ExcCxlCached class
//
// Qualification:   virtual
//
// Export:          public
//
// Return:          none
//
// Parameters:      none
//
// Exceptions:      none
//
////////////////////////////////////////////////////////////////////////////////

ExcCxlCached::~ExcCxlCached()
{
// Nothing to do here
}
{% endhighlight %}


Eighteen lines of comments for a destructor (that is _obviously_ a
destructor for the `ExcCxlCached` `class`) that does
_nothing_! No lies, just noise.



By writing this kind of cruft, you are creating noise for the poor person who
has to come along and _read_ (and _understand_) your intent. The
signal-to-noise ratio here is criminally low.



We're not paid by the line-of-code, people! Please stop! If you want to do more
typing, please expend it on putting some _vowels_ and
_meaning_ into your identifiers. Or writing unit tests.



For this reason I have the following mapping in my `.vimrc`:


{% highlight vim %}
nnoremap <Leader>ic :<C-U>highlight! link Comment Ignore<CR>
{% endhighlight %}


This makes it very easy for me to hide the lies and the noise and
concentrate on the _code_!



Remember: Comments are a failure to express yourself clearly in your code. [Clean Code: A Handbook of Agile
Software Craftsmanship (Robert C. Martin) ](http://tinyurl.com/CleanCodeBook) is recommended reading on the
matter.

