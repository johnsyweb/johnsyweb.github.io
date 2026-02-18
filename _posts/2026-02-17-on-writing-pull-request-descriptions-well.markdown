---
layout: post
category: software-development
title: "On Writing Pull Request Descriptions Well: The Five Cs"
date: 2026-02-17  4:07:21
---

On this week's [Merri Monday Run] I was chatting with a fellow nerd about software development, and the topic of [GitHub pull requests] (PRs) came up; particularly the importance of including a meaningful description in a PR.

As someone who reads a lot more code than I write (don't we all, these days?), and having spent many days acting as a code archaeologist trying to understand _why_ a codebase behaves (or misbehaves) in certain ways, I have come to really appreciate a good PR description.

For some years now I have had a snippet that I use to prompt me to write a good description. [Raycast] expands `!pr` for me to the following, which I think is pretty self-explanatory.

```markdown
#### Card

<!-- Link to Trello card or Jira issue to make it easier for future engineers to
get more context as to the nature of this change. This is the what. -->

[]()

#### Context

<!-- You've had your head in this problem space for longer than your reviewers
have. A couple of sentences as to why you've made this change will help them
review the change. This is the why. -->

#### Change

<!-- Here is where you describe *how* you're solving the problem. Ideally,
you're using meaningful commit messages: 
https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html -->

See individual commits for finer details.

#### Confirmation

<!-- Merging your change is one thing. Here is a good place to link the
dashboard or other tool that you'll look at to check that your change behaves
the way you expect it to. -->

#### Considerations

<!-- A pull request should be the *start* of a conversation, not the end of one.
Here's a good place to pre-empt questions your reviewers may have and answer
them (such as alternative approaches considered and discarded). It's also a good
point to highlight any doubts you may have about your solution. -->
```

To give you an idea of how long I've been using this, a previous incarnation included a "Cc:" section until GitHub introduced the concept of "Reviewers". A couple of examples from 2015 include [Alphanumeric New Relic licence keys] and [Sanitize lockfile]. And my first-ever JavaScript code (parkrun-related, of course): [Introducing the v-index]!

These headings, I think, help give the author and their reviewers a shared structure for understanding a change: what it's for, why it exists, how it works, how to confirm it, and what else has been considered.

Feel free to trim or rename sections to suit you and your team, and I hope it nudges you towards clearer, kinder pull request descriptions.

<!-- Links -->
[Merri Monday Run]: https://merricreekrunning.club/merri-monday/
[GitHub pull requests]: https://docs.github.com/en/pull-requests
[Raycast]: https://www.raycast.com/
[Alphanumeric New Relic licence keys]: https://github.com/newrelic/puppet-nrsysmond/pull/10
[Sanitize lockfile]: https://github.com/denmat/bundler/pull/2
[Introducing the v-index]: https://github.com/fraz3alpha/running-challenges/pull/169
