express = require 'express'
path = require 'path'
bodyParser = require 'body-parser'
authentication = require './authentication'
User = require './users'

config =
  configurable: true,
  value: ->
    alt = {}
    storeKey = (key) -> alt[key] = this[key]
    Object.getOwnPropertyNames(this).forEach storeKey, this
    alt

Object.defineProperty Error.prototype, 'toJSON', config

app = express()

app.use require('stylus').middleware
  src: path.join __dirname, '..', 'client'
  sourcemap: true
app.use require('connect-coffee-script')
  src: path.join __dirname, '..', 'client'
  sourceMap: true
app.use require('serve-favicon') path.join __dirname, '..', 'client', 'favicon.ico'
app.use require('morgan') 'dev'
app.use express.static path.join __dirname, '..', 'client'
app.use require('cookie-parser')()
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true
app.use require('express-session') secret: 'hullaballoo', resave: true, saveUninitialized: true
app.use require('connect-flash')()
app.use authentication.initialize
app.use authentication.session

app.use '/', require './routes'

app.post '/login', authentication.handler

app.post '/register', (req, res, next) ->
  new User(
    email: req.body.email
    key: req.body.key
    vCode: req.body.vCode
    password: req.body.password
  ).save (err, user, count) ->
    if err? then next err
    else res.send "saved!!!"

app.use (req, res) ->
  res.status 404
  res.send 'Not Found'

app.get '*', (req, res, next) ->
  err = new Error 'Not Found'
  err.status = 404
  next err

app.use (err, req, res, next) ->
  console.log err.stack
  res.status err.status or 500
  res.send if app.get('env') is 'development' then err else {}

module.exports = app