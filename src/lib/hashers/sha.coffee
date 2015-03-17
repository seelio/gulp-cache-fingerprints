crypto = require("crypto")

class ShaHasher
  constructor: ->

  hash: (file, entry, done) ->
    return done(new Error("only file buffers are supported")) unless file.isBuffer()

    shaHasher = crypto.createHash("sha1")
    shaHasher.update(file.contents)
    done(null, shaHasher.digest("hex"))


module.exports = ShaHasher
