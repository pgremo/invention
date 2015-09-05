#!/usr/bin/env coffee
debug = require('debug') 'container'
app = require '../app/server'
users = require '../app/users'
orm = require '../app/orm'

port = process.env.PORT or 3000

app.set 'port', port

options =
  adapters:
    mongodb: require 'sails-mongo'
  connections:
    invention:
      adapter: 'mongodb'
      url: process.env.MONGOHQ_URL
  schemas:
    [require '../app/users']
  defaults:
    migrate: 'safe'

orm options, (err, models) ->
  if err? then throw err

  app.models = models.collections

  server = app.listen port, () ->
    debug "Express server listening on port #{port}"