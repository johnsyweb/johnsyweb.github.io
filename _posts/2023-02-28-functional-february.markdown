---
layout: post
category: programming
title: Functional February
date: 2023-02-28 20:03:19.000000000 +11:00
redirect_from:
- "/bit.ly/pajFunctionalFebruary/"
- "/l/FunctionalFebruary/"
---
Having really enjoyed [JavaScript January], I had absolutely no idea which language I was going to choose for [Month 2 of #12in23]. It wasn't until the morning of 1 February that I happened upon the relatively new [`jq` track] on [Exercism]. It had never occurred to me up until that point that as well as being a handy command-line tool for processing [JSON], [`jq`] implements a _language_. It turns out that I had underestimated it, much as I had [AWK] all those years ago.

Did you know you can use `jq` as a simple command-line calculator, for instance?

```sh
jq -cn '6 * 7'
42
```

Or make functions, which help to make filters more legible?

```sh
jq -cn '
def double:
  2 * .
;

[range(10)] | map(double) 
'
[0,2,4,6,8,10,12,14,16,18]
```

Much like in [JavaScript January], I found myself tackling a single exercise from the [`jq` track] in a few minutes each day. I also found that I was having a lot of fun with learning the new language and some days I found myself knocking off two or more excercises of an evening just for fun. Putting the "fun" in "functional", as it were. Soon I found myself at the end of the track with a couple of harder exercises, an evaluator for a very simple subset of [Forth] and solving the [Zebra Puzzle]. It took me a couple of sessions to solve each of these but I was happy with how neat the solutions to these problems were in [`jq`] compared with what they might have looked like in some of the languages with which I am more familiar.

I don't think I'll be reaching for [`jq`] as my go-to language after this month, but I'll certainly be able to use it more handily for building reusuable reports based on [JSON] responses from APIs.

Having accidentally completed the whole [`jq` track] with a few days of the month to go, I revisited [Elixir], which I still really, really like as a language.

One more surprise from _Functional February_? I did most of the exercises in [VS Code] and I liked the experience so much that I wrote this blog post in it!

<!-- Links -->
[AWK]: https://github.com/johnsyweb/totes-awks
[Elixir]: https://exercism.org/tracks/elixir
[Exercism]: https://exercism.org/
[Forth]: https://en.wikipedia.org/wiki/Forth_(programming_language)
[JSON]: https://www.json.org/
[JavaScript January]: {% post_url 2023-01-31-javascript-january %}
[Month 2 of #12in23]: https://exercism.org/challenges/12in23
[VS Code]: https://code.visualstudio.com/
[Zebra Puzzle]: https://en.wikipedia.org/wiki/Zebra_Puzzle
[`jq` track]: https://exercism.org/tracks/jq
[`jq`]: https://stedolan.github.io/jq/
