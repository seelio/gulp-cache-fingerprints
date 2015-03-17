fs = require("fs")
path = require("path")

through = require("through2")
git = require("nodegit")
WError = require("verror").WError
crypto = require("crypto")

computeOptions = require("./lib/compute_options")


abspathToWorkingDir = (repo) ->
  repo.path().replace(new RegExp("\.git/?$"), "")

relpathToFile = (filePath, workingPath, basePath) ->
  filePath \
    .replace(new RegExp("^#{workingPath}/?"), "")
    .replace(new RegExp("^#{basePath}/?"), "")

module.exports = (opts = {}) ->
  defaults =
    root:   null
    build:  null
    base:   "public"
    output: ".fingerprint-cache.json"

  options = computeOptions(defaults, opts)

  options.build ||= options.root
  options.basepath = path.resolve(options.build, options.base)

  cache = {}
  repo = null
  commit = null
  workingDir = null

  setupGitVars = (done) ->
    git.Repository.open(options.root)
      .then (_repo) ->
        repo = _repo
        workingDir = abspathToWorkingDir(repo)
        repo.head()

      .then (ref) ->
        hashOfHEAD = ref.target().tostrS()
        repo.getCommit(hashOfHEAD)

      .then (_commit) ->
        commit = _commit

      .catch (err) ->
        done(new WError(err, "couldn't read git repository"))

      .done ->
        done()

  getTheHash = (file, done) ->
    fileRelpath = relpathToFile(file.path, workingDir, options.base)

    found = (entry) ->
      # In this case, the hashing is done for us
      cache[fileRelpath] = entry.sha()
      done()

    notFound = (err) ->
      # In this case, we need to hash manually
      shaHasher = crypto.createHash("sha1")

      if file.isBuffer()
        shaHasher.update(file.contents)
        digest = shaHasher.digest("hex")

        cache[fileRelpath] = digest
        done()

      else if file.isStream()
        done(new Error("streams aren't supported"))

    commit.getEntry(fileRelpath)
      .then(found, notFound)

  transformHelper = (file, enc, done) ->
    getTheHash(file, done)

  transform = (file, enc, done) ->
    if file.isDirectory()
      return done()

    if file.isNull()
      return done(new Error("file is null, can't hash"))

    if repo
      transformHelper(file, enc, done)
    else
      setupGitVars (err) ->
        return done(err) if err

        transformHelper(file, enc, done)

  flush = (done) ->
    keys = Object.keys(cache)
    filepath = path.resolve(options.root, options.output)

    fs.writeFile filepath, JSON.stringify(cache), (err) ->
      console.log("wrote #{keys.length} hashes", filepath)
      done()


  through.obj(transform, flush)
