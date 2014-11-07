express = require 'express'
path = require 'path'
bodyParser = require 'body-parser'
passport = require 'passport'
EveOnlineStrategy = require('passport-eveonline')

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
app.use passport.initialize()
app.use passport.session()

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  app.models.user.findOne {id: id}, (err, user) ->
    console.log "err=#{err}"
    console.log "user=#{user}"
    done err, user

passport.use new EveOnlineStrategy(
    clientID: 'a9be63771c6549bb9daedb0a3f9beb4e'
    clientSecret: process.env.EVEONLINE_SECRET_KEY
    authorizationURL: 'https://login.eveonline.com/oauth/authorize'
    tokenURL: 'https://login.eveonline.com/oauth/token'
    verifyURL: 'https://login.eveonline.com/oauth/verify'
    callbackURL: 'https://blooming-cliffs-4490.herokuapp.com/api/auth/eveonline/callback'
  ,
    (character, done) ->
      app.models.user.findOne()
        .where id: character.CharacterID
        .then (user) ->
          if user?
            done null, user
          else app.models.user.create {id: character.CharacterID, name: character.CharacterName}, (err, user) ->
            done err, user
        .catch (x) ->
          done x
  )

app.use '/', require './routes'

app.get '/api/auth/eveonline',
  passport.authenticate 'eveonline'

app.get '/api/auth/eveonline/callback',
  passport.authenticate 'eveonline',
    successRedirect: '/'
    failureRedirect: '/'

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

app.post '/api/users/email/validate', (req, res) ->
  app.models.user.count email: req.body.email
    .then (x)-> res.send isValid: x is 0

app.post '/api/users/api/validate', (req, res) ->
  app.models.user.validateAPI req.body.key, req.body.vCode
    .then (x) -> res.send isValid: x
    .catch () -> res.send isValid: false

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