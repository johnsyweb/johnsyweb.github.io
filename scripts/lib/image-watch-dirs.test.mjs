import assert from 'node:assert/strict';
import { mkdir, mkdtemp, rm, access } from 'fs/promises';
import { tmpdir } from 'os';
import { join } from 'path';
import { test } from 'node:test';
import { resolveWatchDirs } from './image-watch-dirs.mjs';

test('creates missing assets/images/utilities so fs.watch can attach', async () => {
  const root = await mkdtemp(join(tmpdir(), 'image-watch-dirs-'));
  try {
    await mkdir(join(root, 'images'));

    const resolved = resolveWatchDirs(root);

    assert.deepEqual(
      resolved.map(({ dir }) => dir),
      ['images', 'assets/images/utilities']
    );
    await access(join(root, 'assets/images/utilities'));
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});

test('is a no-op when watch directories already exist', async () => {
  const root = await mkdtemp(join(tmpdir(), 'image-watch-dirs-'));
  try {
    await mkdir(join(root, 'images'));
    await mkdir(join(root, 'assets/images/utilities'), { recursive: true });

    const resolved = resolveWatchDirs(root);

    assert.equal(resolved.length, 2);
    await access(join(root, 'assets/images/utilities'));
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});
