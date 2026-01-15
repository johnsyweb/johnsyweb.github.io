---
layout: post
categories:
 - personal
 - careerbreak
 - programming
title: Countdown Numbers Game Solver
date: 2025-10-10  5:32:07
---


I've been playing [Summle] for quite some time. It's one of those daily puzzles where you share your results with your friends, and it takes the form of the numbers game from [Countdown] (or [Letters and Numbers], if you prefer). For the unfamiliar, you're given a three-digit target number and six smaller numbers from which to make it using only positive integer arithmetic.


A friend and I came up with our own version of "Hard Mode," whereby we try to solve the daily puzzle as neatly as possible, with the subtotal from each step forming the left-hand side of the next step. This means that our [Signal] chat is littered with messages like this...


Me:

>#Summle #1297: 4/4<br>
>⚪ 🔹 ⚪ = 🟡<br>
>🟡 🔹 ⚪ = 🟡<br>
>⚪ 🔹 ⚪ = 🟡<br>
>🟡 🔹 🟡 = 🟢<br>
>
>Apologies.

Them:

>#Summle #1297: 4/4<br>
>⚪ 🔹 ⚪ = 🟡<br>
>🟡 🔹 ⚪ = 🟡<br>
>🟡 🔹 ⚪ = 🟡<br>
>🟡 🔹 ⚪ = 🟢<br>
>https://summle.net/
>
>Yours is a bit messy

Me:

>Oh, you swine!


There then follows a period of what I have recently learned is called _[incubation]_ before the clean solution becomes apparent. This often involves going for a walk, run, [bike ride], or cooking a meal.

>#Summle #1297: 4/4<br>
>⚪ 🔹 ⚪ = 🟡<br>
>🟡 🔹 ⚪ = 🟡<br>
>🟡 🔹 ⚪ = 🟡<br>
>🟡 🔹 ⚪ = 🟢


Sometimes it's the other way around and _I_ find the clean solution.

Sometimes neither of us finds a clean way, and I cannot be sure whether no such way exists or whether it's eluding us.

Until now.

Yesterday, I had a shower thought: what if I could determine whether there was a neat solution or "golden path," programmatically, without revealing it? Revealing it would really spoil the fun.

And so my new [Countdown Numbers Game Solver] was born, and it's now online for others to play with.

[![Preview of Countdown Numbers Game Solver][Countdown Numbers Game Solver Image]][Countdown Numbers Game Solver]


The ⭐ star icon in the solutions box indicates a "golden path" solution exists where each result flows into the next step. Today, this indicated I had some more work to do to avoid a gentle teasing.

<!-- Links -->

[bike ride]: {% post_url 2025-08-04-i'm-riding-496-km... %}
[Countdown Numbers Game Solver]: {{ site.url }}/countdown/
[Countdown Numbers Game Solver Image]: {{ site.url }}/countdown/og-image.png "Countdown Numbers Game Solver"
[Countdown]: https://www.channel4.com/programmes/countdown
[Letters and Numbers]: https://www.sbs.com.au/ondemand/tv-series/letters-and-numbers
[Signal]: https://signal.org
[Summle]: https://summle.net/
[incubation]: https://en.wikipedia.org/wiki/Incubation_(psychology)
