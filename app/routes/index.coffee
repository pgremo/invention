express = require 'express'
Promise = require 'bluebird'
blueprints = require '../blueprints/index'

router = express.Router()

router.get '/', (req, res) ->
  res.redirect '/invention/index.html'

router.get '/api/typeLookup', (req, res) ->
  blueprints.queryTypes req.query.query
    .then (x) -> res.send x

router.get '/api/bom/:id', (req, res, next) ->
  blueprints.bom req.params.id
    .then (x) ->
      if !x?
        err = new Error 'Not Found'
        err.status = 404
        throw err
      x
    .then (x) ->
      visited = {}
      recur = (y, c) ->
        item = visited[y.id]
        if !item?
          item = id: y.id, total: 0, available: 0, runs: 0
          visited[y.id] = item
        need = if item.available < c then c - item.available else 0
        quantity = y.blueprint?.activities['1'].products[y.id]?.quantity or 1
        runs = Math.ceil need / quantity
        item.available += runs * quantity - c
        item.total += c
        item.label = "#{y.typeName}(#{item.total})"
        item.nodes = for _, value of y.blueprint?.activities['1'].materials
          recur value, runs * value.quantity
        item
      res.send recur x, x.blueprint?.activities['1'].products[x.id]?.quantity
    .catch (error) ->
      next error

module.exports = router