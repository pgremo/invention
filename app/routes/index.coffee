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
  id = req.params.id
  blueprints.bom id
    .then (x) ->
      if !x?
        err = new Error 'Not Found'
        err.status = 404
        throw err
      x
    .then (x) ->
      recur = (y, c, t, p) ->
        quantity = y.blueprint?.activities['1'].products[t]?.quantity or 1
        id: t
        parent: p
        label: y.typeName
        nodes: for key, value of y.blueprint?.activities['1'].materials
          nc = Math.ceil(c / quantity) * value.quantity
          recur value, nc, key, t
      res.send recur x, 1, id
    .catch (error) ->
      next error

module.exports = router