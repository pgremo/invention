express = require 'express'
path = require 'path'
bodyParser = require 'body-parser'
authentication = require './authentication'
neow = require 'neow'

app = express()

clientPath = path.join __dirname, '..', 'client'

app.use require('stylus').middleware src: clientPath, sourcemap: true
app.use require('connect-coffee-script') src: clientPath, sourceMap: true
app.use require('serve-favicon') path.join clientPath, 'favicon.ico'
app.use require('morgan') 'dev'
app.use express.static clientPath
app.use require('cookie-parser')()
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true
app.use require('express-session') secret: 'hullaballoo', resave: true, saveUninitialized: true
app.use require('connect-flash')()
app.use authentication.initialize
app.use authentication.session

app.use '/', require './routes'

app.post '/login', authentication.handler

app.post '/api/users', (req, res, next) ->
  app.models.user.create req.body, (err, user) ->
    if err?
      if err.code is 'E_UNKNOWN'
        {originalError: {name, code}} = err
        if name is 'MongoError' and code is 11000
          console.log 'mongoerror'
          err =
            error: 'E_VALIDATION'
            status: 400
            summary: '1 attribute is invalid'
            invalidAttributes:
              email: [
                rule: 'unique'
                message: "Email is not unique"
              ]
    if err? then next err
    else res.send status: 'OK', userId: user.id

app.post '/api/users/email/validate', (req, res, next) ->
  app.models.user.count email: req.body.email
    .then (x)-> res.send isValid: x is 0

app.post '/api/users/api/validate', (req, res, next) ->
  client = new neow.EveClient keyID: req.body.key, vCode: req.body.vCode
  client
    .fetch 'account:APIKeyInfo'
    .then (x) ->
      res.send isValid: parseInt(x.key.accessMask) & 2 is 2 and x.key.type is 'Account'
    .catch () ->
      res.send isValid: false

app.use (req, res) ->
  res.status 404
  res.send 'Not Found'

app.get '*', (req, res, next) ->
  err = new Error 'Not Found'
  err.status = 404
  next err

app.use (err, req, res, next) ->
  console.log err
  res.status err.status or 500
  res.send message: err.message, error: err

module.exports = app