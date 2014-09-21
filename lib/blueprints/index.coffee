Promise = require 'bluebird'
path = require 'path'
fs = Promise.promisifyAll require 'fs'

types = fs.readFileAsync "#{__dirname}/../data/types.json", 'utf8'
  .then (x) -> JSON.parse x

blueprints = fs.readFileAsync "#{__dirname}/../data/blueprints.json", 'utf8'
  .then (x) -> JSON.parse x

reactions = fs.readFileAsync "#{__dirname}/../data/reactions.json", 'utf8'
  .then (x) -> JSON.parse x

schematics = fs.readFileAsync "#{__dirname}/../data/schematics.json", 'utf8'
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
        item
    for key, value of products
      value.typeName = types[key]
      recur key, []
    products

exports.blueprint = (id) ->
  blueprints.then (x) -> x[id]

exports.bom = (id) ->
  boms.then (x) -> x[id]

exports.type = (id) ->
  types.then (x) -> x[id]
