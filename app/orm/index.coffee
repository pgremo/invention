Waterline = require 'waterline'

module.exports = (options, cb) ->
  models = for x in options.schemas
    Waterline.Collection.extend x

  orm = new Waterline()
  for x in models
    orm.loadCollection x

  orm.initialize options, cb