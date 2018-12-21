---
layout: post
category: UX
title: On meaningful error messages
date: 2018-12-20  0:24:34
---

Today I was trying to make a simple change to a Git repository, privately hosted
with GitHub. I cloned the repository, made the change and went to push it up for
review. The `git push` didn't succeed and I thought maybe I had fat fingered the
remote URL when I cloned the repository (but that _couldn't_ be right because
I'd _successfully_ cloned the repository, right?). I tried removing and
re-adding the remote but still "no dice", as they say.

See if you can understand my initial confusion...

```sh
% git remote -v               
origin    https://github.com/our-organisation/some-repository.git (fetch)
origin    https://github.com/our-organisation/some-repository.git (push)

% git fetch -v origin
From https://github.com/our-organisation/some-repository
 = [up to date]        MO_Adding_ECS_configs             -> origin/MO_Adding_ECS_configs
 = [up to date]        update_gems                       -> origin/update_gems
 
% git push -v origin
Pushing to https://github.com/our-organisation/some-repository.git
remote: Repository not found.
fatal: repository 'https://github.com/our-organisation/some-repository.git/' not found
```


[Some names may have been changed.]

What do you mean, "Repository not found"? Look harder! After spending some time
troubleshooting and getting increasingly frustrated, I sought the counsel of my
colleagues. Some of my colleagues helpfully suggested I try an SSH remote. So I
do this...

```sh
% git remote add ssh git@github.com:our-organisation/some-repository.git

% git fetch ssh
From github.com:our-organisation/some-repository
 * [new branch]        MO_Adding_ECS_configs             -> ssh/MO_Adding_ECS_configs
 * [new branch]        update_gems                       -> ssh/update_gems
 
% git push ssh     
ERROR: Repository not found.
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```


"The correct access rights?"

Well _why didn't you say so?_

It's worth noting at this point that while the SSH failure mode in this scenario
is _slightly_ better, I use HTTPS remotes over SSH because
[GitHub *recommend* HTTPS over SSH](https://help.github.com/articles/which-remote-url-should-i-use/#cloning-with-https-urls-recommended).

I understand that GitHub uses "Not Found" where it means "Forbidden" in some
circumstances to prevent inadvertently reveling the existence of a private
repository:

> Requests that require authentication will return `404 Not Found`, instead of
> `403 Forbidden`, in some places. This is to prevent the accidental leakage of
> private repositories to unauthorized users.

--[GitHub](https://developer.github.com/v3/#authentication)

This is a fairly common practice around the web, indeed it is defined:

> The 404 (Not Found) status code indicates that the origin server did not find
> a current representation for the target resource or **is not willing to
> disclose that one exists.**

--[6.5.4. 404 Not Found, RFC 7231 HTTP/1.1 Semantics and Content](https://tools.ietf.org/html/rfc7231#section-6.5.4) (emphasis mine)

What makes no sense to me is when I am authenticated with GitHub using a
[credential helper](https://help.github.com/articles/caching-your-github-password-in-git/)
*and* I have access to that repository (having successfully cloned and fetched
it) that GitHub would _choose_ to hide its existence from me because of missing
write permissions. That's pretty terrible user experience and cost me a whole
bunch of time when I could have been doing more valuable work.

Checking https://github.com/our-organisation/some-repository/ using a web
browser confirmed that I didn't have write permissions to the repository. Our
team's GitHub administrators were able to grant my team write access in a short
time and I was able to push the branch up. When I did this I got a custom
success message:

```sh
% git push        
Enumerating objects: 23, done.
Counting objects: 100% (23/23), done.
Delta compression using up to 4 threads
Compressing objects: 100% (14/14), done.
Writing objects: 100% (16/16), 2.07 KiB | 706.00 KiB/s, done.
Total 16 (delta 12), reused 0 (delta 0)
remote: Resolving deltas: 100% (12/12), completed with 6 local objects.
remote: 
remote: Create a pull request for 'paj/my-branch' on GitHub by visiting:
remote:      https://github.com/our-organisation/some-repository/pull/new/paj/my-branch
remote: 
To https://github.com/our-organisation/some-repository.git
 * [new branch]        paj/my-branch -> paj/my-branch
```

I like this success message. It's helpful.

**Developers: Failures happen, _plan for them_ and make your error messages as
helpful as your success messages!**
