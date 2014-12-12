gulp = require 'gulp'
Promise = require 'bluebird'
path = require 'path'
fs = Promise.promisifyAll require 'fs'
sqlite = require 'sqlite3'

database = "#{process.cwd()}/data/rhea/eve.db"

gulp.task 'types2json', ->
  db = new sqlite.Database database, sqlite.OPEN_READONLY

  types = {}
  mapper = (err, row) ->
    types[row.typeID] =
      typeName: row.typeName
      groupId: row.groupID
      categoryId: row.categoryID
  completer = () ->
    fs.writeFileAsync 'app/data/types.json', JSON.stringify types, null, 2
    .catch (error) ->
      gulp.err error
  query = """
select t.typeID, t.typeName, t.groupID, c.categoryID
from invTypes t
join invGroups g on g.groupID = t.groupID
join invCategories c on c.categoryID = g.categoryID
where t.published = 1
"""
  db.each query, mapper, completer

gulp.task 'regions2json', ->
  db = new sqlite.Database database, sqlite.OPEN_READONLY

  regions = {}
  mapper = (err, row) ->
    regions[row.regionID] = row.regionName
  completer = () ->
    fs.writeFileAsync 'app/data/regions.json', JSON.stringify regions, null, 2
    .catch (error) ->
      gulp.err error
  db.each 'select regionID, regionName from mapRegions', mapper, completer

gulp.task 'locations2json', ->
  db = new sqlite.Database database, sqlite.OPEN_READONLY

  locations = {}
  mapper = (err, row) ->
    locations[row.itemID] = row.itemName
  completer = () ->
    fs.writeFileAsync 'app/data/locations.json', JSON.stringify locations, null, 2
    .catch (error) ->
      gulp.err error
  db.each 'select itemID, itemName from mapDenormalize', mapper, completer

gulp.task 'stations2json', ->
  db = new sqlite.Database database, sqlite.OPEN_READONLY

  stations = {}
  mapper = (err, row) ->
    stations[row.itemID] = row.itemName
  completer = () ->
    fs.writeFileAsync 'app/data/stations.json', JSON.stringify stations, null, 2
    .catch (error) ->
      gulp.err error
  query = """
select itemID, itemName from mapDenormalize m
join invGroups g on g.groupID = m.groupID
where g.groupName = 'Station'
"""
  db.each query, mapper, completer

gulp.task 'reactions2json', ->
  db = new sqlite.Database database, sqlite.OPEN_READONLY

  reactions = {}
  mapper = (err, row) ->
    reaction = reactions[row.reactionTypeID]
    if !reaction?
      reaction = {
        activities:
          manufacturing:
            materials: []
            products: []
        reactionTypeID: row.reactionTypeID
      }
      reactions[row.reactionTypeID] = reaction
    if row.input is 1
      reaction.activities.manufacturing.materials.push {typeID: row.typeID, quantity: row.qty}
    else
      reaction.activities.manufacturing.products.push {typeID: row.typeID, quantity: row.qty}
  completer = () ->
    fs.writeFileAsync 'app/data/reactions.json', JSON.stringify reactions, null, 2
    .catch (error) ->
      gulp.err error
  query = """
SELECT
`itr`.`reactionTypeID`,
`itr`.`input`,
`itr`.`typeID`,
`itr`.`quantity`,
itr.quantity * IFNULL(IFNULL(dta.valueInt, dta.valueFloat), 1) as qty
FROM
`invtypereactions` `itr`
LEFT JOIN `dgmtypeattributes` `dta` ON `itr`.`typeID` = `dta`.`typeID` AND `dta`.`attributeID` = 726;
"""
  db.each query, mapper, completer

gulp.task 'schematics2json', ->
  db = new sqlite.Database "#{process.cwd()}/data/oceanus/eve.db", sqlite.OPEN_READONLY

  reactions = {}
  mapper = (err, row) ->
    reaction = reactions[row.schematicID]
    if !reaction?
      reaction = {
        activities:
          manufacturing:
            materials: []
            products: []
        schematicID: row.schematicID
      }
      reactions[row.schematicID] = reaction
    if row.isInput is 1
      reaction.activities.manufacturing.materials.push {typeID: row.typeID, quantity: row.quantity}
    else
      reaction.activities.manufacturing.products.push {typeID: row.typeID, quantity: row.quantity}
  completer = () ->
    fs.writeFileAsync 'app/data/schematics.json', JSON.stringify reactions, null, 2
    .catch (error) ->
      gulp.err error
  query = """
select r.schematicID, r.isInput, r.typeID, r.quantity
from planetSchematicsTypeMap r
"""
  db.each query, mapper, completer

