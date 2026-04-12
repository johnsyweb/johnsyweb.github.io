---
layout: post
categories:
  - geek
  - careerbreak
title: Making Arlo geofencing behave again
date: 2026-04-12 20:59:00 +1000
---

I run an [Arlo]-based home security setup, and most of the time it behaves as expected. A few months ago, Arlo shipped a major app update that broke the automations we depended on. I reconstructed them, only to encounter a new problem: whenever we came home, our phones would hound us with alerts that somebody was in the house. Yes. We know!

I am good with troubleshooting and logic, so I endeavoured to fix it myself. Eventually I was satisfied I was not the component at fault, and I filed a support case.

Narrowing the fault down took a while. When I came home, the system should have switched from Arm away to Standby, but the arrive automation would not trigger on my phone. The leave automation was fine. A manual test of the arrive rule worked. _K_’s phone triggered the arrive rule when she got home.

Support’s first explanation was that schedules and geofencing could not be relied on at the same time, and that I should pick one. This was a major regression compared with the functionality the system had when we bought the devices. Later, a support message suggested clearing old handsets from the geofence device list; sensible hygiene, and worth doing, but it did not address why the same regression appeared for so many people after a major app update.

Along the way I read enough of the [Arlo community][arlo community] to see I was not alone. I also worked through [Arlo’s own guidance][arlo support] on my phone - location access, the lot - without changing the outcome.

Then came a line I have kept verbatim:

> Also we are pleased to inform you that this is an known issue.

Who would be pleased by such a thing?

Of course I accept that front-line staff do not ship the app. Still, letting a regression linger that long, while customers juggle armed away mode and false comfort, is not acceptable for a security product. Most engineers I know take [continuous delivery][continuous delivery] seriously. In [_Continuous Delivery_][continuous delivery book], Jez Humble and David Farley describe pipelines where bad change is rolled back quickly and fixed forward, rather than leaving users in limbo for months. I am unlikely to buy another Arlo device.

### What actually fixed it

I removed almost all of the configuration, then rebuilt the rules:

1. Remove _K_’s granted access from my account.
2. Remove my phone from the geofence device list.
3. Delete every automation (schedules and geofence rules).
4. Recreate them with the same intent: a morning schedule to Standby when someone is home, an evening schedule to Arm home, a leave rule to Arm away when everyone is gone, and an arrive rule back to Standby when anyone returns.
5. Register only my current phone for geofencing first.
6. Re-invite _K_ with the access she needs.

After that, arrive and leave both behaved. If you are stuck in a similar loop, that sequence may be worth trying before you throw the device out.

### Alternatives considered

I looked at [Shortcuts][apple shortcuts] and [IFTTT][ifttt]-style workarounds, using the phone’s own location to drive a separate action, but I wanted the vendor path to work first. Longer term, during this [career break], I am also looking at [Home Assistant][home assistant] as a place to tinker properly with home automation, on my own terms, and with tests I control.

If Arlo’s engineers ship a durable fix, I will be glad for everyone still on the platform. Until then, this post is the note I wish I had read months ago.

<!-- Links -->

[apple shortcuts]: https://support.apple.com/guide/shortcuts/
[arlo community]: https://community.arlo.com
[arlo support]: https://support.arlo.com
[Arlo]: https://www.arlo.com
[continuous delivery book]: https://www.informit.com/store/continuous-delivery-reliable-software-releases-through-9780321601919
[continuous delivery]: https://martinfowler.com/bliki/ContinuousDelivery.html
[home assistant]: https://www.home-assistant.io/
[ifttt]: https://ifttt.com
[career break]: {% post_url 2025-05-05-career-break %}
