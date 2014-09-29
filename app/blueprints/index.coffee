Promise = require 'bluebird'
path = require 'path'
_ = require 'underscore'
fs = Promise.promisifyAll require 'fs'

types = fs.readFileAsync "#{__dirname}/types.json", 'utf8'
  .then (x) -> JSON.parse x

typeLookup = types
  .then (x) -> _.pairs x

blueprints = fs.readFileAsync "#{__dirname}/blueprints.json", 'utf8'
  .then (x) -> JSON.parse x

reactions = fs.readFileAsync "#{__dirname}/reactions.json", 'utf8'
  .then (x) -> JSON.parse x

schematics = fs.readFileAsync "#{__dirname}/schematics.json", 'utf8'
  .then (x) -> JSON.parse x

products = Promise.all [blueprints, reactions, schematics]
  .then (sources) ->
    result = {}
    for data in sources
      for _, value of data
        produces = value.activities["1"]?.products
        if produces? and Object.keys(produces).length is 1
          for id, _ of produces
            result[id] = value
    result

boms = Promise.all [products, types]
  .spread (products, types) ->
    recur = (itemId, visited) ->
      if visited.indexOf itemId < 0
        visited.push itemId
        item = products[itemId]
        for key, value of item?.activities["1"].materials
          bp = recur key, visited
          value.blueprint = bp if bp?
          value.typeName = types[key]
          value.id = key
        item
    things = {}
    for key, value of products
      things[key] = blueprint: value, typeName: types[key], id: key
      recur key, []
    things

exports.bom = (id) -> boms.then (x) -> x[id]

exports.queryTypes = (q) ->
  pattern = new RegExp q, 'i'
  typeLookup
    .then (x) ->
      x.filter (y) -> pattern.test y[1]
