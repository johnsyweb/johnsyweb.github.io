---
layout: post
categories:
  - geek
  - security
title: "Passwordless should reduce risk and friction"
date: 2026-03-26 09:00:00 +1100
---

I recently received an email from a travel-related service announcing a "new login experience":

> We're letting you know about an update to how you log in to your account. Logging in is now faster and more secure on recognised web-browsers and devices.
>
> Instead of entering your account number and password every time you access your account, you'll receive a one-time 6-digit code sent to your email or mobile to confirm your identity.

This sounds modern and reassuring. But when <abbr title="One-time password">OTP</abbr> via email or <abbr title="Short Message Service">SMS</abbr> becomes the primary login method, the result can be brittle: not as secure, and not as fast, as advertised.

![Text message showing a one-time verification code][verification-code-screenshot]

_An <abbr title="Short Message Service">SMS</abbr> verification code: simple in calm conditions, fragile when phone numbers, networks, or delivery paths are unreliable._

## Why this is a problem

If the only way in is a code sent to your email address or phone number, the system is effectively single-factor possession login. You are proving access to a channel, not necessarily strong control of identity.

That is not the same thing as phishing-resistant authentication.

It also creates practical reliability problems. On my last overseas trip, my Australian mobile provider's roaming costs were extortionate, so I used a local <abbr title="Subscriber Identity Module">SIM</abbr> and number. In that scenario, any service that insists on OTP to the original number can turn routine account access into unnecessary drama.

The "faster" claim is hard to take seriously too. Login is only faster when the message arrives quickly, the right channel is reachable, and your telecom or email provider is behaving itself. If any of those fail, the flow is slower than using a password manager with strong <abbr title="Multi-factor authentication">MFA</abbr>.

## Threat model matters

Security claims should match a clear threat model.

OTP by SMS can be vulnerable to SIM-swap and number-porting attacks ([NIST Digital Identity Guidelines], [CISA on SIM swapping]). OTP by email inherits the security posture of your mailbox, so if your email account is compromised the attacker may also receive login codes. I wrote about that broader risk in [Improving Online Security].

So yes, this approach may reduce one risk (password reuse), but it can introduce or amplify other risks and failure modes.

## Before the migration plan: why the rush?

When a service forces a login change quickly, it is fair to ask why now.

Sometimes there is a good operational reason: active credential-stuffing, a surge in account takeovers, compliance deadlines, or a known weakness in a legacy authentication stack. If so, say that plainly. Users are usually more understanding when they are given honest context and practical guidance.

If there has been a breach or serious incident, transparency matters even more. A rushed rollout without context can look like security-by-announcement rather than security-by-design.

## How this could be done better

First: do not roll your own authentication stack unless you absolutely must. Use a mature identity platform that supports modern standards.

Second: make [passkeys] the primary sign-in path. They are materially stronger against phishing ([FIDO on passkey phishing resistance]) and far less dependent on fragile message delivery.

Third: keep OTP as a recovery mechanism, not the default daily login flow.

A practical migration path could look like this:

1. Add passkeys alongside existing login methods.
2. Encourage passkey adoption and provide recovery codes.
3. Gradually demote weak OTP-only flows to fallback and recovery use.

Passwordless is a good direction. But passwordless should reduce risk and friction, not relocate them.

<!-- Links -->
[Improving Online Security]: {% post_url 2019-01-21-improving-online-security %}
[CISA on SIM swapping]: https://www.cisa.gov/news-events/cybersecurity-advisories/aa23-320a "CISA advisory describing SIM swapping as part of modern social-engineering attacks"
[FIDO on passkey phishing resistance]: https://fidoalliance.org/passkeys/ "Passkeys from the FIDO Alliance"
[NIST Digital Identity Guidelines]: https://pages.nist.gov/800-63-3/sp800-63b.html "NIST SP 800-63B Digital Identity Guidelines"
[passkeys]: https://fidoalliance.org/passkeys/ "Passkeys from the FIDO Alliance"
[verification-code-screenshot]: /images/2026-03-26-verification-code-sms.png "SMS one-time verification code"
