through = require("through2")
gutil = require("gulp-util")

Options = require("./lib/options")
Git = require("./lib/git")
Cache = require("./lib/cache")

GitHasher = require("./lib/hashers/git")
ShaHasher = require("./lib/hashers/sha")

relpathToFile = (filePath, workingPath) ->
  filePath.replace(new RegExp("^#{workingPath}/?"), "")

module.exports = (opts = {}) ->
  options = new Options(opts)
  cache = new Cache(options)
  git = new Git(options)
  githasher = new GitHasher
  shahasher = new ShaHasher

  transformHelper = (file, enc, done) ->
    fileRelpath = relpathToFile(file.path, git.abspathToWorkingDir())

    cacheTheHash = (err, hash) ->
      return done(err) if err?
      cache.set(fileRelpath, hash)
      done()

    git.getFile fileRelpath, (err, gitEntry) ->
      if gitEntry?
        githasher.hash(file, gitEntry, cacheTheHash)
      else
        shahasher.hash(file, gitEntry, cacheTheHash)


  transform = (file, enc, done) ->
    # Silently ignore directories
    return done() if file.isDirectory()

    if git.repo
      transformHelper(file, enc, done)
    else
      git.initialize (err) ->
        return done(err) if err

        transformHelper(file, enc, done)

  flush = (done) ->
    cache.write (err) ->
      return done(err) if err?
      gutil.log("Cached #{cache.keys().length} hashes to #{cache.cachePath()}")
      done()


  through.obj(transform, flush)
