---
layout: post
categories:
  - geek
  - tech
  - email
title: 'noreply@ considered harmful'
date: '2026-10-18 01:29:00'
---

With apologies to [Dijkstra][dijkstra], this is about a smaller kind of harm than unstructured control flow, and a more common one: the `noreply@` address or emails that direct responses to an "unmanaged" mailbox.

Can anyone explain why this is desirable for an email recipient?

Picture the scene: a new customer buys something online, a receipt arrives, something looks off, hitting "Reply" is the obvious next step, and they're instantaneously ignored. You've given them a strong signal about how valued their custom is.

In the workplace this is just as bad: an email arrives missing some vital context, and hitting "Reply" is the obvious way to seek or provide clarification, or keep progressing towards the desired outcome. When the address refuses the reply, progress stops.

Email is a [two-way communication](https://en.wikipedia.org/wiki/Two-way_communication) mechanism.

A `noreply@`, `no-reply@`, or `do-not-reply@` address tells the recipient: we may speak to you; you may not speak back here. That might be convenient for the sender's queue. For the customer, colleague, or partner it is an unwelcome barrier between you.

Feedback that never arrives is still feedback you needed. It could be praise: a thank-you that tells you what to keep doing. It could be a plea for help: the tracking number is wrong, the invoice does not match, the login code never came, the change request needs one clarifying question. Closing the reply path does not remove the need. It only moves the cost onto the person who was ready to tell you.

[Twilio][twilio] puts it bluntly: a no-reply address is the email equivalent of hanging up on customers who call with questions. [Mailjet][mailjet] makes the same point from a marketing angle: it's a brick wall.

I'm yet to see a valid defence of this strategy.

The worst defence I have seen is that there's already a self-service customer portal. Not one of your customers cares about your ticketing system. How you manage communications from your customers is your own affair, not your customer's!

If you email me, you would not expect me to respond via the postal service or a fax machine. Why would you expect me to go to a web-based ticketing system when the reply button is right there built into every single mail client? Accept a response. Route it into Zendesk, Jira, a shared inbox, a spreadsheet, a carrier pigeon if you must. That plumbing is invisible by design. Closing Reply and pointing at a portal is asking me to change channel after you chose email.

[Shopify][shopify] and [Zendesk][zendesk] both seem to agree that while your workload goes down by refusing replies, trust and ease of contact go with it.

Even with operational system emails, a reply should land with whomever supports that system. Treating `noreply@` as the default for anything automated trains your organisation to value silence over signal.

## What to do instead

- Send from a monitored address when a human might reasonably reply (`support@`, `orders@`, `billing@`, a team alias, something with a name).
- If send and receive must differ, set an explicit `Reply-To` to a monitored inbox, or send from a real mailbox and route afterwards. Do not rely on people discovering a buried contact form after Reply fails.
- Never silently drop replies. Bounce noise is ugly; invisibility is worse.
- Treat inbound replies as a feedback channel: triage praise, questions, and "please help" into the places your organisation already learns from customers.

## Further reading

- [Edsger W. Dijkstra, "Go To Statement Considered Harmful"][dijkstra] (title lineage)
- [Twilio: Why you should not use noreply@][twilio]
- [Mailjet: Noreply email and why it is bad for email marketing][mailjet]
- [Shopify: Do-not-reply email pros, cons, and tips][shopify]
- [Zendesk: Do-not-reply emails, pros, cons, and best practices][zendesk]
- [Bento: Stop using Reply-To to catch marketing replies][bento]
- [Omnisend: Noreply email, examples and alternatives][omnisend]

<!-- links -->

[bento]: https://bentonow.com/posts/do-not-use-reply-to
[dijkstra]: https://dl.acm.org/doi/10.1145/362929.362947
[mailjet]: https://www.mailjet.com/blog/deliverability/noreply-email-address/
[omnisend]: https://www.omnisend.com/blog/noreply-email/
[shopify]: https://www.shopify.com/blog/do-not-reply-email
[twilio]: https://www.twilio.com/en-us/blog/insights/why-you-should-not-use-noreplydomain-com-in-your-emails
[zendesk]: https://www.zendesk.com/blog/customer-service/satisfaction/reply-emails-pros-cons-best-practices/
