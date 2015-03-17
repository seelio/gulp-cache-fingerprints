fs = require("fs")
path = require("path")

through = require("through2")
gutil = require("gulp-util")

Options = require("./lib/options")
Git = require("./lib/git")
Sha = require("./lib/sha")
Cache = require("./lib/cache")

relpathToFile = (filePath, workingPath, basePath) ->
  filePath
    .replace(new RegExp("^#{workingPath}/?"), "")

module.exports = (opts = {}) ->
  options = new Options(opts)
  git = new Git(options)
  sha = new Sha
  cache = new Cache(options)

  getTheHash = (file, done) ->
    fileRelpath = relpathToFile(file.path, git.abspathToWorkingDir())

    found = (entry) ->
      # In this case, the hashing is done for us
      cache.set(fileRelpath, entry.sha())
      done()

    notFound = (err) ->
      # In this case, we need to hash manually
      if file.isBuffer()
        digest = sha.digest(file.contents)
        cache.set(fileRelpath, digest)
        done()

      else if file.isStream()
        done(new Error("streams aren't supported"))

    git.getFile fileRelpath, (err, file) ->
      if file?
        found(file)
      else
        notFound()

  transformHelper = (file, enc, done) ->
    getTheHash(file, done)

  transform = (file, enc, done) ->
    if file.isDirectory()
      return done()

    if file.isNull()
      return done(new Error("file is null, can't hash"))

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
