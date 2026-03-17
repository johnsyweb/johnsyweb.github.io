---
layout: post
category: geek
title: "Copy a directory structure with rsync (and no files)"
date: 2026-03-17 21:00:00 +1100
---

This post started off life as a note in [Obsidian] but I figure it may be useful to others, and sharing is caring.

Once a year I create a new project directory for my tax return with sub‑directories for the various components.

Creating that structure by hand is tedious, but I only do it once a year, so I never remember the one‑liner to copy last year's layout without bringing all of last year's files along for the ride.

Here is the version I'll be able to find next year.

In my case, the existing folder lives in a project directory:

```bash
cd /path/to/1. Projects
```

I want a sibling directory for the new financial year, with the same sub‑directories but no files:

```bash
mkdir "FY2026 Tax Return - paj"
```

Now I can copy the directory structure from last year into the new folder using [`rsync`] (a command‑line tool for efficiently copying and synchronising files and directories):

```bash
rsync -a --include '*/' --exclude '*' "FY2025 Tax Return - paj/" "FY2026 Tax Return - paj/"
```

That command:

- **`-a`**: preserves permissions and timestamps and recurses into sub‑directories.
- **`--include '*/'`**: includes all directories (the trailing slash is important).
- **`--exclude '*'`**: excludes all files.

After this runs, `FY2026 Tax Return - paj` has the same directory tree as `FY2025 Tax Return - paj`, but every directory is empty and ready for this year's documents.

At that point I move last year's folder into my `4. Archive` area and keep the new year under `1. Projects`, following the [PARA method] I use for both files and notes in Obsidian.

If you are nervous about what [`rsync`] will do, you can add `-n` for a dry‑run first:

```bash
rsync -an --include '*/' --exclude '*' "FY2025 Tax Return - paj/" "FY2026 Tax Return - paj/"
```

That will print what _would_ happen without changing anything on disk, which is a handy safety net when you're scripting against your tax records.

<!-- Links -->
[Obsidian]: https://obsidian.md/
[PARA method]: https://fortelabs.com/blog/para/
[`rsync`]: https://rsync.samba.org/
