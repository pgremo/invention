Promise = require 'bluebird'
path = require 'path'
fs = Promise.promisifyAll require 'fs'

types = fs.readFileAsync "#{__dirname}/types.json", 'utf8'
  .then (x) -> JSON.parse x

blueprints = fs.readFileAsync "#{__dirname}/blueprints.json", 'utf8'
  .then (x) -> JSON.parse x

reactions = fs.readFileAsync "#{__dirname}/reactions.json", 'utf8'
  .then (x) -> JSON.parse x

schematics = fs.readFileAsync "#{__dirname}/schematics.json", 'utf8'
  .then (x) -> JSON.parse x

products = Promise.all [blueprints]
  .then (sources) ->
    result = {}
    for data in sources
      for _, value of data
        produces = value.activities.manufacturing?.products
        if produces? and produces.length is 1
          for item in produces
            result[item.typeID] = value
    result

boms = Promise.all [products, types]
  .spread (products, types) ->
    recur = (itemId, visited) ->
      if visited.indexOf itemId < 0
        visited.push itemId
        item = products[itemId]
        if item? and item.activities.manufacturing.materials?
          for value in item.activities.manufacturing.materials
            bp = recur value.typeID, visited
            value.blueprint = bp if bp?
            value.typeName = types[value.typeID]
        item
    things = {}
    for key, value of products
      things[key] = blueprint: value, typeName: types[key], typeID: key
      recur key, []
    things

typeLookup = boms.then (x) -> [key, value.typeName] for key, value of x when value?.typeName?

exports.bom = (id) -> boms.then (x) -> x[id]

exports.queryTypes = (q) ->
  pattern = new RegExp q, 'i'
  typeLookup.then (x) -> x.filter (y) -> pattern.test y[1]
