module.exports = (gulp, opts) ->
  Promise = require 'bluebird'
  path = require 'path'
  fs = Promise.promisifyAll require 'fs'
  sqlite = require 'sqlite3'

  gulp.task 'types2json', ['downloadSDE'], (cb) ->
    db = new sqlite.Database "#{process.cwd()}/data/#{opts.eveRelease}/#{opts.eveVersion}/eve.db", sqlite.OPEN_READONLY

    types = {}
    mapper = (err, row) ->
      types[row.typeID] =
        typeName: row.typeName
        groupId: row.groupID
        categoryId: row.categoryID
    completer = () ->
      fs.writeFileAsync 'app/data/types.json', JSON.stringify types, null, 2
      cb()
    query = """
  select t.typeID, t.typeName, t.groupID, c.categoryID
  from invTypes t
  join invGroups g on g.groupID = t.groupID
  join invCategories c on c.categoryID = g.categoryID
  where t.published = 1
  """
    db.each query, mapper, completer

  gulp.task 'regions2json', ['downloadSDE'], (cb) ->
    db = new sqlite.Database "#{process.cwd()}/data/#{opts.eveRelease}/#{opts.eveVersion}/eve.db", sqlite.OPEN_READONLY

    regions = {}
    mapper = (err, row) ->
      regions[row.regionID] = row.regionName
    completer = () ->
      fs.writeFileAsync 'app/data/regions.json', JSON.stringify regions, null, 2
      cb()
    db.each 'select regionID, regionName from mapRegions', mapper, completer

  gulp.task 'locations2json', ['downloadSDE'], (cb) ->
    db = new sqlite.Database "#{process.cwd()}/data/#{opts.eveRelease}/#{opts.eveVersion}/eve.db", sqlite.OPEN_READONLY

    locations = {}
    mapper = (err, row) ->
      locations[row.itemID] = row.itemName
    completer = () ->
      fs.writeFileAsync 'app/data/locations.json', JSON.stringify locations, null, 2
    db.each 'select itemID, itemName from mapDenormalize', mapper, completer

  gulp.task 'stations2json', ['downloadSDE'], (cb) ->
    db = new sqlite.Database "#{process.cwd()}/data/#{opts.eveRelease}/#{opts.eveVersion}/eve.db", sqlite.OPEN_READONLY

    stations = {}
    mapper = (err, row) ->
      stations[row.itemID] = row.itemName
    completer = () ->
      fs.writeFileAsync 'app/data/stations.json', JSON.stringify stations, null, 2
      cb()
    query = """
  select itemID, itemName from mapDenormalize m
  join invGroups g on g.groupID = m.groupID
  where g.groupName = 'Station'
  """
    db.each query, mapper, completer

  gulp.task 'reactions2json', ['downloadSDE'], (cb) ->
    db = new sqlite.Database "#{process.cwd()}/data/#{opts.eveRelease}/#{opts.eveVersion}/eve.db", sqlite.OPEN_READONLY

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
      cb()
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

  gulp.task 'schematics2json', ['downloadSDE'], (cb) ->
    db = new sqlite.Database "#{process.cwd()}/data/#{opts.eveRelease}/#{opts.eveVersion}/eve.db", sqlite.OPEN_READONLY

    schematics = {}
    mapper = (err, row) ->
      reaction = schematics[row.schematicID]
      if !reaction?
        reaction = {
          activities:
            manufacturing:
              materials: []
              products: []
          schematicID: row.schematicID
        }
        schematics[row.schematicID] = reaction
      if row.isInput is 1
        reaction.activities.manufacturing.materials.push {typeID: row.typeID, quantity: row.quantity}
      else
        reaction.activities.manufacturing.products.push {typeID: row.typeID, quantity: row.quantity}
    completer = () ->
      fs.writeFileAsync 'app/data/schematics.json', JSON.stringify schematics, null, 2
      cb()
    query = """
  select r.schematicID, r.isInput, r.typeID, r.quantity
  from planetSchematicsTypeMap r
  """
    db.each query, mapper, completer

