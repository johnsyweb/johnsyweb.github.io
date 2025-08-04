---
layout: post
category: Security
title: Improving Online Security
date: 2019-01-21 11:37:00.000000000 +11:00
redirect_from:
- "/bit.ly/improving-online-security/"
- "/l/improving-online-security/"
---
The revelation of the ["Collection #1" data
breach](https://www.troyhunt.com/the-773-million-record-collection-1-data-reach/)
highlights, once again, that we do a poor job of keeping ourselves safe online.
January is a good time for setting personal goals and if I could recommend one
goal for you, it would be to improve your online security. I'm not a security
professional but my work involves online identity management and I find our
community's behaviours fascinating. This blog post contains free, unsolicited
advice, so you are guaranteed value for money but do give it some consideration.

### Get a Password Manager

![Password Entry]({{ site.baseurl }}{% link /images/2019-01-21-password-entry.png %})

First thing's first... get yourself a password manager! No, really. I used
[LastPass](https://www.lastpass.com/) for many years and found it sufficient but
a couple of security issues gave me pause for thought. I recently switched to
[1Password](https://1password.com/) (the migration was very straightforward) and
have been impressed with its slick user interfaces and its Watchtower
functionality for highlighting where I may be vulnerable online.

I have literally hundreds of online accounts, many of which are years old and I
have no idea how secure my credentials are with those services. I know from
services such as [Have I Been Pwned (HIBP)](https://haveibeenpwned.com/) that
some of these services have stored my credentials in plain text and those
credentials have subsequently leaked, so I treat all online services with
suspicion. Keeping track of all these accounts is only manageable with a
password manager.

### Use Strong, Unique, Memorable, Diceware Passphrases Locally

There are some places where password managers don't work, such as unlocking your
computer's operating system and getting into your password manager. Since your
online security is only as strong as the weakest link, these logins need to be
strong enough to keep others out and memorable enough to let you in!

I'd like to see the word "Password" eradicated from all authentication setup
scenarios as it encourages poor security choices. Passwords are guessable by
other humans and are quickly found by computer algorithms. Where you see this
word, read it as "pass _phrase_". 

[The diceware method](https://en.wikipedia.org/wiki/Diceware) of creating a
sequence of words makes for strong login credentials. To make these words
memorable, compose an image in your head that joins the words together. The
[XKCD "correct horse battery staple" comic](https://www.xkcd.com/936/) is a good
illustration of this concept but _please_ don't use "correct horse battery
staple" as your pass-phrase, [it has already been
breached](https://haveibeenpwned.com/Passwords)!

### Use Long, Unique, Random Passphrases Online

Your password manager doesn't care for the legibility of your credentials, so
turn up the strength of your "password" to the maximum. 1Password and LastPass
offer generators that will do the heavy lifting for you.

![Password Generation]({{ site.baseurl }}{% link /images/2019-01-21-password-generation.png %})

Sometimes websites, even ones I'd expect to know better, such as those belonging
to telecommunications companies will tell us that our generated passwords are
"too long" or "contain invalid characters". I'm pretty certain that these are
storing our passwords in plain text and are therefore insecure. Which is the
perfect segue to the next piece of advice.

### Never Reuse Credentials

It's safe to assume that your credentials from at least one online service will
be leaked at some point in time. See [HIBP](https://haveibeenpwned.com/), it
probably has been already! When this happens, those credentials are likely be
used in credential stuffing attacks. If an attacker gets hold of your
credentials for, say, your favourite band's online discussion forum it would be
bad for them to impersonate you on that service but potentially far worse for
them to impersonate you using the same credentials to log into your social media
or email service.

### Enable Two-Factor Authentication (2FA)

Multi-factor authentication (MFA) is not available everywhere but it is
available on many major online services. The site [Two Factor Auth
(2FA)](https://twofactorauth.org/) keeps a great list and provides us with ways
to contact those who don't yet offer 2FA.

I remember reading the real life horror story
[Hacked!](https://www.theatlantic.com/magazine/archive/2011/11/hacked/308673/?single_page=true)
in April 2012 and sitting up late that night enabling 2FA on a bunch of
accounts. At the time I used the popular Google Authenticator application to
manage my time-based one-time passwords (TOTP) but have since switched to using
[Authy](https://authy.com/), which makes moving from one mobile device to
another much more convenient.

The only times I have ever found 2FA to be an inconvenience are those when my
browser has crashed or Google has logged me out in the middle of a Hangout (or
"Meet").

I don't consider SMS-based MFA to be secure [due to the risk that SMS messages
may be intercepted or
redirected](https://fortune.com/2016/07/26/nist-sms-two-factor/) so prefer TOTP
or Universal 2nd Factor (U2F) devices, where available. When presented with
backup codes, keep these safe as you would your birth certificate, passport or
driving licence.

### Conclusion

_Please_ keep strong, unique pass-phrases in a password manager and secure your
email and social media accounts with 2FA.

Let me know how you go!
