nodegit = require("nodegit")
WError = require("verror").WError

class Git
  constructor: (@options) ->

  initialize: (done) ->
    nodegit.Repository.open(@options.root)
      .then (@repo) =>
        @repo.head()

      .then (ref) =>
        hashOfHEAD = ref.target().toString()
        @repo.getCommit(hashOfHEAD)

      .then (@commit) =>
        (->)()

      .catch (err) ->
        done(new WError(err, "couldn't load directory as git repository"))

      .done ->
        done()

  getFile: (filepath, done) ->
    found = (entry) ->
      done(null, entry)

    notFound = (err) ->
      done(err)

    @commit.getEntry(filepath)
      .then(found, notFound)

  abspathToWorkingDir: ->
    @repo.path().replace(new RegExp("\.git/?$"), "")

module.exports = Git
