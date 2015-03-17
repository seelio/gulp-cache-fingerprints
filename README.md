# Gulp - Cache Fingerprints

This is a part of our solution for asset caching.

## Overview

1. Get hash of file
  - If file is tracked by git, use git's hash
    (Hash is equal to `git hash-object <file>`)
  - If file is not tracked by git, hash it ourselves
    (Hash is equal to `shasum <file>`)
2. Write all hashes to file

## Usage

```coffee
# gulpfile.coffee

cacheFingerprints = require("gulp-cache-fingerprints")

gulp.task "fingerprint", ->
  srcs = [
    "public/**/*"
  ]

  opts =
    root: __dirname.toString()
    build: "build"

  gulp.src(srcs)
    .pipe(cacheFingerprints(opts))
```

## Options

#### `opts.root` (required)

This must be the absolute path to your git working directory.

#### `opts.build` (optional)

This should be the relative path from `opts.root` to your build directory.
You only need to set this if you have a build directory,
and if your build directory and working directory are different.

#### `opts.base` (optional)

**Default: public**

This should be the relative path from `opts.build` to your public assets directory.

#### `opts.output` (optional)

**Default: .fingerprint-cache.json**

This should be relative to the root directory.

