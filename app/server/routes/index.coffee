express = require 'express'
blueprints = require '../blueprints'

router = express.Router()

router.get '/', (req, res) ->
  res.render 'index', title: 'Invention'

router.get '/:id', (req, res) ->
  blueprints.blueprint req.params.id
    .then (result) ->
      res.render 'blueprint', blueprint: JSON.stringify result, null, ' '

module.exports = router