class GitHasher
  constructor: ->

  hash: (file, entry, done) ->
    done(null, entry.sha())


module.exports = GitHasher
