computeOptions = (defaults, opts) ->
  options = {}

  for own key, val of defaults
    options[key] = val

  for own key, val of opts
    options[key] = val

  options

module.exports = computeOptions
