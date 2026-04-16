---
layout: post
category: systems
title: Plan for Failure
date: 2026-04-16  5:03:30
---

## This post is about post

I'm so meta (but not "Meta")!

## Some context

I grew up in the UK, where, by and large, post was delivered through a slot in the front door called a [letterbox].

When we moved to Melbourne in 2006, we took on a [Post Office Box] (PO Box), following a recommendation from a friend whose mail had gone missing. Post here is not delivered through the door, and letters left in roadside mailboxes are exposed to [Melbourne Weathers] and passers-by. A PO Box protects us from those risks.

During the pandemic, we started using our residential address for postal deliveries because there was always someone home. Since then, we have continued to have post delivered here, while I still check the PO Box periodically (and now Australia Post notifies me when mail arrives there).

## The reason for this post about post

Back in March, somebody I have never met sent me a letter from the UK. I was told to expect it, but I was not given a timeframe or any tracking ID.

I largely did not think about this delivery, especially with air travel between the UK and Australia somewhat disrupted at the moment by what I shall call the Taco and Bebe Show. It occurred to me last week that it had been a while since I had heard anything, so I contacted the sender to ask whether they had a tracking ID.

The response came back:

> I have checked the tracking number and it says that they tried to deliver on 7th April but no-one seemed to be in. It says they have left a note about how to make further arrangements. Can you let me know if that is the case please.

7 April? The very day they said they attempted delivery. We checked all around the front of the property. No note. We checked the [security camera] footage. No delivery.

I asked whether [Australia Post tracking] gave any further information.

They responded with a screenshot from [Royal Mail], reproduced here, that does indeed say: "Our delivery partner tried to deliver your parcel on 07-04-2026 but there didn't seem to be anyone in. They've left a note about how to make further arrangements."

![Royal Mail tracking page showing a claimed delivery attempt on 7 April 2026 with a card left notice](/images/2026-04-16-royal-mail-tracking.png)

I put the same tracking number into the [Australia Post] website.

![Australia Post tracking page showing the attempted delivery date as 20 March 2026](/images/2026-04-16-australia-post-tracking.png)

They attempted delivery, not on 7 April, but on 20 March. I lodged an enquiry online and went to bed.

The next morning I took my photo ID to the local post office and asked whether I was too late to collect the package. I was. I was told that I should have come to collect the package sooner as after they'd failed to deliver it they only keep it for so long. I asked how I was meant to know to collect it and they said I should have had a card. I should indeed. I didn't.

At the staff member's recommendation, I called 13 POST and asked whether the package could be intercepted and delivered to me. Maybe. They'd try.

Today I had a phone call following up my enquiry lodged in the early hours of last Wednesday morning. It was a very frustrating call because I was told that Australia Post no longer leaves cards to let customers know about attempted deliveries, and that they rely on their [MyPost] service instead because it is "more reliable".

I have just found this information online:

> To be more sustainable, we’re moving away from leaving cards after an attempted delivery. If you have a MyPost personal account, we’ll let you know about an attempted delivery with a digital notification instead.
>
> Our digital collection notifications provide more accurate and useful information than the card for an attempted delivery. You can choose whether you receive notifications by email, app or SMS, by selecting your notification preferences.

**Source:** <https://auspost.com.au/receiving/parcel-deliveries/missed-parcel-deliveries>

However, international packages are not tracked in MyPost because they did not originate in Australia Post's system. If you do not have a MyPost account, the very best of luck to you.

When I asked how I was meant to know there was a package awaiting me at the post office, I was told I should have known from the tracking number, which I did not have. Australia Post stopped sending letters from the post office to recipients because, in most cases, recipients had collected the package before the letter arrived.

So now my package is circumnavigating the globe. What a waste!

## If you're sending us a package from overseas

Please use our PO Box address and please send us a tracking ID, if you have one.

## If you're replacing a manual, physical system with an automated, digital system

For goodness' sake consider the failure modes and plan for them.

In this case, an international package that required a signature and was not delivered *clearly* needed a physical card.


<!-- Links -->

[Australia Post tracking]: https://auspost.com.au/mypost/track/search
[Australia Post]: https://auspost.com.au/mypost/track/search
[letterbox]: https://en.wikipedia.org/wiki/Letter_box
[Melbourne Weathers]: https://rjh.org/~rjh/melbourne/
[MyPost]: https://auspost.com.au/mypost
[Post Office Box]: https://auspost.com.au/receiving/manage-your-mail/po-boxes-and-private-bags
[Royal Mail]: https://www.royalmail.com/track-your-item
[security camera]: {% post_url 2026-04-12-arlo-geofencing-workaround %}
