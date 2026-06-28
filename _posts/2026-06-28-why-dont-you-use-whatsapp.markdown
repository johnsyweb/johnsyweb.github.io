---
layout: post
categories:
    - geek
title: "Why don't you use WhatsApp?"
date: '2026-06-28  7:10:13'
updated_at:
redirect_from: /l/NotsApp
---

## “Why don't you use WhatsApp?”

The short answer is privacy.

I should be upfront: I do still have a WhatsApp account. Kids' sports teams use
it to coordinate with parents, and I check those groups when necessary. The app
is hidden from my phone's home screen, notifications are off, and WhatsApp does not
have access to my contacts. Please do not rely on me seeing a message there.
[Signal][signal] or [email][contact] are much better ways to reach me.

## The longer answer

Following [WhatsApp's January 2021 privacy-policy
update][whatsapp-update], I switched to [Signal][signal] once it became clearer
how much user data Meta would share across its services.

The 2021 update did not mean WhatsApp could read your encrypted message contents.
It did clarify that WhatsApp collects and shares extensive metadata and
business-interaction data with Meta, increasing the risk that personal
information tied to your account (phone number, device info, contacts list,
usage patterns, IP address, profile details, and business-chat data) can be used
across Meta's advertising and product ecosystem. WhatsApp's own [follow-up
post][whatsapp-blog] stressed that end-to-end encryption for personal chats was
unchanged; reading the updated policy is what prompted my move, not rumour.

## What end-to-end encryption covers and what it does not

WhatsApp uses [the Signal protocol][whatsapp-signal-protocol] for end-to-end
encryption of message contents, so messages between senders and recipients are
encrypted in transit and not readable by WhatsApp itself. The policy changes
that prompted my move did not claim to break that encryption for standard chats,
but they did expand what non-message data WhatsApp could surface to Meta, and how
business messages and integrations might expose inputs to Meta systems. That blur between protected
message content and broadly collected metadata created a privacy model I was not
comfortable with. [Wikipedia's summary of the reception to WhatsApp's security
and privacy features][whatsapp-wikipedia] is a useful overview if you want the
broader history.

## Why metadata matters

Even when message text is encrypted, metadata (who you message, when, how
frequently, group membership, phone numbers, profile picture, and IP or device
data) can be extremely revealing. Metadata can be used to build behavioural
profiles, target advertising, and infer relationships or routines. Because
Meta's business model depends heavily on data-driven targeting across its
services, allowing WhatsApp to share metadata with Meta gives the company
leverage it can use beyond the chat app itself. That is a core reason to prefer
a service whose design minimises metadata collection and sharing. [The
Guardian's piece from the time][guardian] explains this well for a general
audience.

## Business integrations, AI features, and additional exposure

WhatsApp's evolving features, such as business messaging, cloud backups, and
integrations with Meta's AI and business tools, create additional vectors where
inputs and attachments can be stored or processed outside end-to-end-encrypted
channels. Where messages interact with business systems or cloud services, those
interactions may be logged or exposed in ways that standard peer-to-peer
encrypted chats are not. That further reduces the practical privacy guarantees
for many real-world uses. [Georgetown Law Tech Review's
analysis][georgetown] discusses how users interpreted, and sometimes
misinterpreted, the 2021 changes.

## Why I chose Signal

[Signal][signal] is architected to reduce both content and metadata exposure. It
minimises the information it holds about users (for example, it does not retain
contact lists or detailed metadata), defaults to privacy-preserving options, and
is governed by an independent non-profit rather than an advertising-driven
corporation. For me, that means fewer ways my family's and my contacts' data can
be stitched into a broader profiling system. You can [download Signal][signal]
or [message me there][signal-me] if you would like to stay in touch that way. I
[donate to Signal][signal-donate] and encourage others to do the same. Donations
help pay for the servers and ongoing development that keep Signal independent,
with no ads and no surveillance business model.

## Meta's broader data practices

Meta's products (Facebook, Instagram, WhatsApp) increasingly operate as a single
ecosystem for data: cross-platform sign-ins, ad targeting, and shared
infrastructure mean data collected in one product can influence experiences in
another. If you are trying to limit how much a single company can assemble about
you, avoiding that entire ecosystem reduces the surface area for behavioural
tracking and targeted profiling. That is why I do not use Facebook or Instagram
either. I wrote about [my beef with Facebook][facebook-beef] back in 2011; the
incentives have not improved since.

## Practical considerations

Kids' sport runs on WhatsApp. Training times, game-day changes, and car-pool
arrangements live in parents' group chats, and that is where the organisers
already are. I am not willing to miss something our children need me to know
because I have principles about messaging apps.

So I compromise rather than quit entirely. I keep WhatsApp for those logistics
groups only, check them when I need to, and treat the account as single-purpose.
I am clear with people that they should not expect a timely reply there. For
anything outside a team broadcast, [Signal][signal], iMessage, or
[email][contact] are what I actually read.

Even a minimal account has rough edges. I avoid cloud backups, business chats,
and anything that might copy conversation data outside the default
end-to-end-encrypted path. Screenshots and forwarded messages are outside my
control once someone else takes them. And like any company, Meta can be compelled
to hand over data it holds; giving it less to hold in the first place is the
main lever I have.

## In summary

![Facebook Messenger, Instagram, and WhatsApp avoided; email, iMessage, and Signal preferred.][messaging-summary]

## Further reading

* [WhatsApp Security Whitepaper: Signal protocol for end-to-end encryption][whatsapp-signal-protocol]
* [WhatsApp Help Center: Answering your questions about the January 2021 privacy policy update][whatsapp-update]
* [WhatsApp Blog: Giving more time for our recent update][whatsapp-blog]
* [The Guardian: Is it time to leave WhatsApp, and is Signal the answer?][guardian]
* [Reception and criticism of WhatsApp security and privacy features (Wikipedia)][whatsapp-wikipedia]
* [Georgetown Law Tech Review: A mass exodus from WhatsApp to Signal?][georgetown]

[signal]: https://signal.org/
[signal-me]: https://signal.me/#eu/3XOS3lWi12hyZcRRcg6XmwkafhSDz
[signal-donate]: https://signal.org/donate/
[contact]: /contact/
[whatsapp-signal-protocol]: https://www.whatsapp.com/security/WhatsApp-Security-Whitepaper.pdf
[whatsapp-update]: https://faq.whatsapp.com/595724415641642/
[whatsapp-blog]: https://blog.whatsapp.com/giving-more-time-for-our-recent-update
[guardian]: https://www.theguardian.com/technology/2021/jan/24/is-it-time-to-leave-whatsapp-and-is-signal-the-answer
[whatsapp-wikipedia]: https://en.wikipedia.org/wiki/Reception_and_criticism_of_WhatsApp_security_and_privacy_features
[georgetown]: https://georgetownlawtechreview.org/a-mass-exodus-from-whatsapp-to-signal-and-other-privacy-focused-messaging-apps-may-have-been-misinformed/GLTR-02-2021/
[facebook-beef]: {% post_url 2011-01-08-new-beef-with-facebook %}
[messaging-summary]: /images/2026-06-28-messaging-summary.png "Messaging preferences summary"
