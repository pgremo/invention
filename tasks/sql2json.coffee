gulp = require 'gulp'
Promise = require 'bluebird'
path = require 'path'
fs = Promise.promisifyAll require 'fs'
sqlite = require 'sqlite3'

gulp.task 'types2json', ->
  db = new sqlite.Database "#{process.cwd()}/data/hyperion.db", sqlite.OPEN_READONLY

  types = {}
  mapper = (err, row) ->
    types[row.typeID] = row.typeName
  completer = () ->
    fs.writeFileAsync 'lib/data/types.json', JSON.stringify types, null, 2
    .catch (error) ->
      gulp.err error
  db.each 'select typeID, typeName from invTypes where published = 1', mapper, completer

gulp.task 'reactions2json', ->
  db = new sqlite.Database "#{process.cwd()}/data/hyperion.db", sqlite.OPEN_READONLY

  reactions = {}
  mapper = (err, row) ->
    reaction = reactions[row.reactionTypeID]
    if !reaction?
      reaction = {
        activities:
          '1':
            materials: {}
            products: {}
        reactionTypeID: row.reactionTypeID
      }
      reactions[row.reactionTypeID] = reaction
    if row.input is 1
      reaction.activities['1'].materials[row.typeID] = {quantity: row.quantity}
    else
      reaction.activities['1'].products[row.typeID] = {quantity: row.quantity}
  completer = () ->
    fs.writeFileAsync 'lib/data/reactions.json', JSON.stringify reactions, null, 2
    .catch (error) ->
      gulp.err error
  query = """
select r.reactionTypeID, r.input, r.typeID, r.quantity from invTypeReactions r
join invTypes rt on r.reactionTypeID = rt.typeID
where rt.published = 1
"""
  db.each query, mapper, completer

gulp.task 'schematics2json', ->
  db = new sqlite.Database "#{process.cwd()}/data/hyperion.db", sqlite.OPEN_READONLY

  reactions = {}
  mapper = (err, row) ->
    reaction = reactions[row.schematicID]
    if !reaction?
      reaction = {
        activities:
          '1':
            materials: {}
            products: {}
        schematicID: row.schematicID
      }
      reactions[row.schematicID] = reaction
    if row.isInput is 1
      reaction.activities['1'].materials[row.typeID] = {quantity: row.quantity}
    else
      reaction.activities['1'].products[row.typeID] = {quantity: row.quantity}
  completer = () ->
    fs.writeFileAsync 'lib/data/schematics.json', JSON.stringify reactions, null, 2
    .catch (error) ->
      gulp.err error
  query = """
select r.schematicID, r.isInput, r.typeID, r.quantity
from planetSchematicsTypeMap r
"""
  db.each query, mapper, completer

