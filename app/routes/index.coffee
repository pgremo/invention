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
      recur = (y, c, t) ->
        quantity = y?.activities['1'].products[t]?.quantity or 1
        for key, value of y?.activities['1'].materials
          nc = Math.ceil(c / quantity) * value.quantity
          {
            id: key
            parent: t
            label: "#{value.typeName}(#{nc})"
            nodes: recur value.blueprint, nc, key
          }
      c = x.activities['1'].products[id].quantity
      res.send
          id: id
          parent: 0
          label: "#{x.typeName}(#{c})"
          nodes: recur x, 1, req.params.id
    .catch (error) -> next error

module.exports = router