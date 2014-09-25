express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
logger = require 'morgan'
routes = require './routes'

app = express()

app.use favicon path.join __dirname, '..', 'client', 'favicon.ico'
app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true
app.use cookieParser()
app.use express.static path.join __dirname, '..', 'client'

app.use '/', routes

app.use (req, res) ->
  res.status 404
  res.send 'Not Found'

app.get '*', (req, res, next) ->
  err = new Error 'Not Found'
  err.status = 404
  next err

app.use (err, req, res, next) ->
  res.status err.status or 500
  res.send if app.get('env') is 'development' then err else {}

module.exports = app