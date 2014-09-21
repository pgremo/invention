express = require 'express'
Promise = require 'bluebird'
blueprints = require '../blueprints/index'
archy = require 'archy'

router = express.Router()

router.get '/', (req, res) ->
  res.render 'index', title: 'Invention'

router.get '/:id', (req, res, next) ->
  blueprints.bom req.params.id
    .then (x) ->
      if !x?
        err = new Error 'Not Found'
        err.status = 404
        throw err
      x
    .then (x) ->
      recur = (y, c, t) ->
        quantity = y?.activities["1"].products[t]?.quantity or 1
        for key, value of y?.activities["1"].materials
          nc = Math.ceil(c / quantity) * value.quantity
          {
            id: key
            parent: t
            label: "#{value.typeName}(#{nc})"
            nodes: recur value.blueprint, nc, key
          }
      c = x.activities["1"].products[req.params.id].quantity
      raw =
        id: req.params.id
        parent: 0
        label: "#{x.typeName}(#{c})"
        nodes: recur x, 1, req.params.id
      result = archy raw
      res.render 'blueprint', blueprint: result, raw: raw
    .catch (error) -> next error

module.exports = router