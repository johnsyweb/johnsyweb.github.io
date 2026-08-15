import { existsSync, mkdirSync } from 'fs';
import { join } from 'path';

export const DEFAULT_IMAGE_WATCH_DIRS = ['images', 'assets/images/utilities'];

/**
 * Resolve image watch directories under root, creating any that are missing.
 * Utility screenshot originals are not committed (only WebP outputs are), so a
 * clean clone will not have assets/images/utilities until something creates it.
 */
export function resolveWatchDirs(root, dirs = DEFAULT_IMAGE_WATCH_DIRS) {
  return dirs.map((dir) => {
    const fullPath = join(root, dir);
    if (!existsSync(fullPath)) {
      mkdirSync(fullPath, { recursive: true });
    }
    return { dir, fullPath };
  });
}
