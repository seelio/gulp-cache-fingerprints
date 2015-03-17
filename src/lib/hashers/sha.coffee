crypto = require("crypto")

class ShaHasher
  constructor: ->

  hash: (buffer) ->
    shaHasher = crypto.createHash("sha1")

    shaHasher.update(buffer)
    shaHasher.digest("hex")


module.exports = Sha
