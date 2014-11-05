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
      me = req.query.me or 1.0
      visited = {}
      recur = (y, c, ma) ->
        item = visited[y.typeID]
        if not item?
          item = id: y.typeID, total: 0, available: 0, runs: 0
          visited[y.typeID] = item
        need = if item.available < c then c - item.available else 0
        quantity = y.blueprint?.activities.manufacturing.products[0]?.quantity or 1
        runs = Math.ceil need / quantity
        item.available += runs * quantity - c
        item.total += c
        item.label = y.typeName
        if y.blueprint?
          item.nodes = for value in y.blueprint.activities.manufacturing.materials
            recur value, (Math.max runs, Math.ceil (runs * value.quantity * ma).toFixed 2), 1.0
        item
      recur x, x.blueprint?.activities.manufacturing.products[0]?.quantity, me
    .then (x) ->
      res.send x
    .catch (x) ->
      next x

module.exports = router