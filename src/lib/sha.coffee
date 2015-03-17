crypto = require("crypto")

class Sha
  constructor: ->

  digest: (buffer) ->
    shaHasher = crypto.createHash("sha1")

    shaHasher.update(buffer)
    shaHasher.digest("hex")


module.exports = Sha
