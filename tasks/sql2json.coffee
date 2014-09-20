gulp = require 'gulp'
Promise = require 'bluebird'
path = require 'path'
fs = Promise.promisifyAll require 'fs'
sqlite = require 'sqlite3'

db = new sqlite.Database "#{process.cwd()}/data/hyperion.db", sqlite.OPEN_READONLY

gulp.task 'types2json', ->
  types = {}
  mapper = (err, row) ->
    types[row.typeID] = row.typeName
  completer = () ->
    fs.writeFileAsync 'lib/data/types.json', JSON.stringify types, null, 2
    .catch (error) ->
      gulp.err error
  db.each 'select typeID, typeName from invTypes where published = 1', mapper, completer

