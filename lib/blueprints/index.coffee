Promise = require 'bluebird'
path = require 'path'
fs = Promise.promisifyAll require 'fs'

blueprints = fs.readFileAsync "#{__dirname}/../data/blueprints.json", 'utf8'
  .then (x) -> JSON.parse x
  .catch (error) -> console.log error

products = blueprints
  .then (data) ->
    result = {}
    for key, value of data
      for id, _ of value.activities["1"]?.products
        result[id] = value
    result

types = fs.readFileAsync "#{__dirname}/../data/types.json", 'utf8'
  .then (x) -> JSON.parse x

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
