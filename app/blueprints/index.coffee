Promise = require 'bluebird'
data = require '../data'

products = Promise.all [data.types, data.blueprints]
  .spread (types, sources...) ->
    result = {}
    for source in sources
      for key, value of source when types[key]?
        produces = value.activities.manufacturing?.products
        if produces? and produces.length is 1
          for item in produces when types[item.typeID]?
            result[item.typeID] = value
    result

boms = Promise.all [products, data.types]
  .spread (products, types) ->
    recur = (itemId, visited) ->
      if visited.indexOf itemId < 0
        visited.push itemId
        item = products[itemId]
        if item? and item.activities.manufacturing.materials?
          for value in item.activities.manufacturing.materials
            bp = recur value.typeID, visited
            value.blueprint = bp if bp?
            value.typeName = types[value.typeID].typeName
        item
    things = {}
    for key, value of products
      things[key] = blueprint: value, typeName: types[key].typeName, typeID: key
      recur key, []
    things

typeLookup = boms.then (x) -> [key, value.typeName] for key, value of x when value?.typeName?

exports.bom = (id) -> boms.then (x) -> x[id]

exports.queryTypes = (q) ->
  pattern = new RegExp q, 'i'
  typeLookup.then (x) -> x.filter (y) -> pattern.test y[1]
