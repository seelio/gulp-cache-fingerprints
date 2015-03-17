fs = require("fs")
path = require("path")

class Cache
  constructor: (@options) ->
    @datastore = {}

  set: (relpath, value) ->
    key = @_key(relpath)
    @datastore[key] = value

  keys: ->
    Object.keys(@datastore)

  write: (done) ->
    fs.writeFile(@cachePath(), JSON.stringify(@datastore), done)

  cachePath: ->
    path.resolve(@options.root, @options.output)

  _key: (relpath) ->
    relpath.replace(new RegExp("^#{@options.base}/*"), "")


module.exports = Cache
