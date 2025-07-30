---
layout: post
category: iOS
title: Formatting iOS email signatures is a pain
date: 2025-07-30 14:28:59
redirect_from: /sig/
---

Despite the title, I am not going to moan about the user interface, but rather share how I get around the strange font choices and line breaks that happen when I edit my email signature using iOS's native Mail application. It being [Better to Light a Candle Than to Curse the Darkness][better-to-light-a-candle].

Given the lack of formatting controls in the settings sheet, I figured that the inbuilt Notes app would serve me well. It didn't. It made a similar mess of the formatting.

The solution is to use [Pages][pages]. When you select the text, each line should end with a paragraph break (&para;), not just a line break (&crarr;). I now have a Signature.pages file in my [iCloud Drive][icloud-drive], which has each of my signatures ready to copy and paste into iOS when I need it.

![Screenshot of signature formatting in iOS][signature-image]{:.responsive-img}

My signatures all start with the [standard delimiter][standard-delimiter] (exactly two hyphens, followed by a space, alone on a line), of course.

<!-- Links -->

[better-to-light-a-candle]: {% post_url 2022-03-12-better-to-light-a-candle-than-to-curse-the-darkness %}
[pages]: https://www.apple.com/pages/
[icloud-drive]: https://support.apple.com/en-au/HT204025
[standard-delimiter]: https://en.wikipedia.org/wiki/Signature_block#Standard_delimiter
[signature-image]: /images/2025-07-30-signature.jpeg
