express = require 'express'
blueprints = require '../blueprints/index'
archy = require 'archy'

router = express.Router()

router.get '/', (req, res) ->
  res.render 'index', title: 'Invention'

router.get '/:id', (req, res) ->
  blueprints.bom req.params.id
    .then (x) ->
      recur = (y, c, t) ->
        quantity = y?.activities["1"].products[t]?.quantity or 1
        for key, value of y?.activities["1"].materials
          nc = Math.ceil(c / quantity) * value.quantity
          {
            label: "#{value.typeName}(#{nc})"
            nodes: recur value.blueprint, nc, key
          }
      c = x.activities["1"].products[req.params.id].quantity
      result = archy
        label: "#{x.typeName}(#{c})"
        nodes: recur x, 1, req.params.id
      res.render 'blueprint', blueprint: result

module.exports = router