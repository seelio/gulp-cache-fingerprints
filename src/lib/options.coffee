class Options
  constructor: (@userOptions) ->
    @options = {}

    @_setOptionsToDefaults()
    @_setOptionsWithUserOverrides()
    @_setOptionsThatAreStillBlank()
    
    for own key, value of @options
      opts =
        value: value
        writable: false
        enumerable: true

      Object.defineProperty(@, key, opts)

    Object.freeze(@options)

  defaults:
    root:   null
    build:  null
    base:   "public"
    output: ".fingerprint-cache.json"

  _setOptionsThatAreStillBlank: ->
    @options.build ||= @options.root

  _setOptionsWithUserOverrides: ->
    for own key, val of @userOptions
      @options[key] = val

  _setOptionsToDefaults: ->
    for own key, val of @defaults
      @options[key] = val


module.exports = Options
