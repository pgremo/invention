express = require 'express'
blueprints = require '../blueprints/index'
archy = require 'archy'

router = express.Router()

router.get '/', (req, res) ->
  res.render 'index', title: 'Invention'

router.get '/:id', (req, res) ->
  blueprints.bom req.params.id
    .then (x) ->
      recur = (y) ->
        for key, value of y?.activities["1"].materials
          {
            label: "#{value.typeName}(#{value.quantity})"
            nodes: recur value.blueprint
          }
      result = archy
        label: "#{x.typeName}(#{x.activities["1"].products[req.params.id].quantity})"
        nodes: recur x
      res.render 'blueprint', blueprint: result

module.exports = router