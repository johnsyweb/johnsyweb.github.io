---
layout: post
category: programming
title: Mechanical March
date: 2023-03-31 10:17:21.000000000 +11:00
redirect_from:
- "/bit.ly/pajGolang/"
- "/l/Golang/"
---
Hot on the heels of [Functional February] came [Mechanical March] in [Exercism's
#12in23 challenge]. There was a veritable feast of languages from which to
choose and I opted for [Go] (apparently it's [not] _[Golang]_ despite all of the
easier-to-find on the web references to the contrary. Go is one of the
dominant languages in my domain at work, where tools like [Docker] and
[Kubernetes] are in plentiful supply. I last played with Go in December 2012
when I was considering working for one of Go's biggest users and remember quite
liking it after years of C, C++ and Python. I remember really liking the
approach of returning errors as a second return value, so that it is handled by
the caller. The language was only about three years old then, so I was keen to
see how it had matured.

[The only valid measurement of code quality: WTFs/minute], or so it's said. I
had so many WTF moments playing with Go this month that I am just chosing to
share a few of them with you.

Before I get into Go, I'm going to call out how excellent [asdf] is when working
wth multiple programming languages. Install the relevant language plugin from
[asdf-plugins] (Go's is called `golang` just because), `asdf install golang
latest && asdf local golang latest` and off you go.

Oh and how good is [Dash] for docs? I've been using it with [Alfred] for years
but it also integrates really nicely with VSCode, which is my editor of choice
these days.

## Comments

I am considerably less anti-comment (and put much less stock into what the
referenced author has to say) than when I wrote [Comments Are Lies!] in 2012 but
`/* increment i by one */` style comments still make my teeth itch. Exercism's
[Weather Forecast exercise] was _painful_ to work through. [Documenting this
module] following the [Go Doc Comments] specification felt like an exercise in
futility.  Comments must start with specific words and end with a "period". Does
this really make code or generated content easier to understand?

## Parsing and formatting dates and times

Most languages I have worked with use [`strftime(3)`]-style formatting
specifications for handling date and time strings. The other timestamp etched in
my programmer's brain is 00:00:00 UTC on Thursday, 1 January 1970, the beginning
of the [Unix epoch]. These are well-understood and recognised concepts.

Imagine my surprise when the format specifiers I had been using for over a
quarter of a century didn't work when undertaking the [Booking up for Beauty]
exercise. A bit of digging around informed me...

```go
// The reference time used in these layouts is the specific time stamp:
//
//  01/02 03:04:05PM '06 -0700
//
// (January 2, 15:04:05, 2006, in time zone seven hours west of GMT).
```

--<https://github.com/golang/go/blob/5e191f8/src/time/format.go>

The _what now_!?

I'm sure there'd be some who'd argue that this is as simple as 1, 2, 3, 4, 5, 6,
7 (which just happens to be a Monday) but developers working with the Gregorian
calendar in other languages have been seasoned to use the International Standard
(i.e. 2006-01-02T15:04:05Z-07:00) and 6, 1, 2, 15, 4, 5, 6, -7 is arguably not
as simple nor as useful as a mnemonic. This made the [Booking up for Beauty]
exercise more confusing in Go than I would have expected. The `Description()`
implementation may be harder to understand to folks coming from other languages
because the placeholders are indistinguishable from regular text.

I found [JavaScript's zero-based months] easier to reason with.

## How to test whether a key is present within a `map`

This is a doozy. Given a map...

```go
units := map[string]int{
  "quarter_of_a_dozen": 3,
  "half_of_a_dozen":    6,
  "dozen":              12,
  "small_gross":        120,
  "gross":              144,
  "great_gross":        1728,
 }
```

...how do you determine whether `units` contains the `string` key "dozen"?
Accessing a missing element using an index expression (`units["score"]`) returns
a zero value for the stored type.

First I checked out [Map types] in the The Go Programming Language
Specification. Nothing there. Next I went to [Index expressions] and failed to
spot the pertinent text (hence "[doc: defragment index expressions spec for map
types]"). From there I ended up on a blog post, [Go maps in action], which has
the answer:

> A two-value assignment tests for the existence of a key:
>
> `i, ok := m["route"]`

I mentioned earlier how I liked the Go approach of [returning an _error_ as the
second return value][multiple-returns]. It transpires that there's _another_
opposing "comma ok" idiom for [maps]. Because of course there is. To make
matters more confusing `i := units["score"]` will set `i` to `0` in the example
above but `i, ok := units["score"]` is also valid with a second return value.
After a month with the language I'm still unsure how you specify exactly how
many return values to expect in these cases, since the following doesn't
compile:

```go
func GetUnit(units map[string]int, item string) (int, bool) {
 return units[item] // not enough return values
}
```

...but this does...

```go
func GetUnit(units map[string]int, item string) (int, bool) {
 i, ok := units[item]
 return i, ok
}
```

OK Go!

## Named Captures in Regular expressions

One of the many things I like about Ruby is how easy it is to use regular
expressions to get things done. I guess it gets this from Perl and AWK.

For example to get a couple of words:

```ruby
/^(?<first>\w+)\s+(?<second>\w+)$/.match('Hello World') # => #<MatchData "Hello World" first:"Hello" second:"World">
```

In Go, I have three [problems] (as my long-suffering friend Marcus points out).
After specifying the regular expression, I need to create my own `map` to get
 the indexes for the named matches.

```go
package main

import (
 "fmt"
 "regexp"
)

func main() {
 matcher := regexp.MustCompile(`^(?P<first>\w+)\s+(?P<second>\w+)`)
 matches := matcher.FindStringSubmatch("Hello World")
 namedMatches := map[string]string{}
 for i, name := range matcher.SubexpNames() {
  namedMatches[name] = matches[i]
 }
 fmt.Println(namedMatches)
}
```

```sh
go run main.go
# map[:Hello World first:Hello second:World]
```

So much boilerplate code to get stuff done. I had similarly verbose experiences
with simple programming concepts like returning a positive integer (there's no
`abs()` in the standard library and finding an element in ~~an array~~ _a slice_
-- roll your own `for`-loop). And to get the last item from a slice, you need
first to determine the length of said slice. I really expected Go to be
_considerably_ better than its C-like predecessors but it's not and I'm not even
going to dig into pointers in this post. It's already too ranty!

While I am glad I have enough familiarity with its syntax to be able to review
Go code at work, it is not a language I'll be rushing to for solving hobby
programming problems.

Okay, April, what do you have in store for me?

<!-- Bookmarks for this post -->
[Alfred]: https://www.alfredapp.com/blog/productivity/dash-quicker-api-documentation-search/
[Booking up for Beauty]: https://exercism.org/tracks/go/exercises/booking-up-for-beauty/solutions/johnsyweb
[Comments Are Lies!]: /blog/2012/10/31/comments-are-lies/
[Dash]: https://kapeli.com/dash
[Docker]: https://www.docker.com
[Documenting this module]: https://exercism.org/tracks/go/exercises/weather-forecast/solutions/johnsyweb
[Exercism's #12in23 challenge]: https://exercism.org/challenges/12in23
[Functional February]: /blog/2023/02/28/functional-february/
[Go Doc Comments]: https://tip.golang.org/doc/comment
[Go maps in action]: https://go.dev/blog/maps
[Go]: https://go.dev
[Golang]: https://trends.google.com/trends/explore?date=all&q=golang,Go%20programming%20language,Go,%2Fm%2F05b1n7
[Index expressions]: https://go.dev/ref/spec#Index_expressions
[JavaScript's zero-based months]: https://stackoverflow.com/a/1453095/78845
[Kubernetes]: https://kubernetes.io
[Map Types]: https://go.dev/ref/spec#Map_types
[Mechanical March]: https://youtu.be/_PPXEJZ7gOg
[The only valid measurement of code quality: WTFs/minute]: https://www.osnews.com/story/19266/wtfsm/
[Unix epoch]: https://en.wikipedia.org/wiki/Unix_time
[Weather Forecast exercise]: https://exercism.org/tracks/go/exercises/weather-forecast
[`strftime(3)`]: https://man7.org/linux/man-pages/man3/strftime.3.html
[asdf-plugins]: https://github.com/asdf-vm/asdf-plugins
[asdf]: https://asdf-vm.com/
[doc: defragment index expressions spec for map types]: https://go-review.googlesource.com/c/go/+/480315/1
[maps]: https://go.dev/doc/effective_go#maps
[multiple-returns]: https://go.dev/doc/effective_go#multiple-returns
[not]: https://go.dev/doc/faq#go_or_golang
[problems]: https://blog.codinghorror.com/regular-expressions-now-you-have-two-problems/
