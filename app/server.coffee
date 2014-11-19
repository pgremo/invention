express = require 'express'
path = require 'path'
bodyParser = require 'body-parser'
passport = require 'passport'
EveOnlineStrategy = require('passport-eveonline')
url = require 'url'
jwt = require 'jwt-simple'
moment = require 'moment'
session = require 'express-session'
MongoStore = require('connect-mongo') session

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
app.use session
  secret: process.env.SESSION_SECRET
  resave: true
  saveUninitialized: true
  store: new MongoStore(url: process.env.MONGOHQ_URL)
app.use passport.initialize()
app.use passport.session()

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  app.models.user.findOne {id: id}, (err, user) ->
    user = if not user? then false else user
    done err, user

passport.use new EveOnlineStrategy(
    clientID: 'a9be63771c6549bb9daedb0a3f9beb4e'
    clientSecret: process.env.EVEONLINE_SECRET_KEY
    callbackURL: '/api/auth/eveonline/callback'
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

app.use (req, res, next) ->
  parsed = url.parse req.url, true
  token = req.body?.access_token or parsed.query.access_token or req.headers['x-access-token']
  if token?
    try
      decoded = jwt.decode token, process.env.TOKEN_SECRET
      if decoded.exp <= Date.now()
        res.end 'Access token has expired', 400
      else
        app.models.user.findOne {id: parseInt decoded.iss}, (err, user) ->
          req.user = user
          next()
    catch err
      next()
  else
    next()

app.use '/', require './routes'

app.get '/api/auth/eveonline',
  passport.authenticate 'eveonline'

app.get '/api/auth/eveonline/callback', (req, res, next) ->
  passport.authenticate('eveonline', (err, user) ->
    if err? then return next err
    if not user then return res.redirect '/'
    app.models.user.findOne {id: user.id}, (err, user) ->
      token = jwt.encode {
        iss: user.id,
        exp: moment().add(7, 'days').valueOf()
      }, process.env.TOKEN_SECRET
      res.redirect "/?token=#{token}")(req, res, next)

app.get '/api/auth/refresh', (req, res, next) ->
  app.models.user.findOne {id: user.id}, (err, user) ->
    token = jwt.encode {
      iss: user.id,
      exp: moment().add(7, 'days').valueOf()
    }, process.env.TOKEN_SECRET
    res.send token

app.get '/api/signout', (req, res) ->
  req.logout()
  res.redirect '/'

ensureUser = (req, res, next) ->
  if not req.user?
    error = new Error()
    error.status = 401
    next error
  else
    next()

app.post '/api/users', ensureUser, (req, res) ->
  res.send status: 'OK'

app.get '/api/users', ensureUser, (req, res) ->
   res.send req.user

app.post '/api/users/email/validate', (req, res) ->
  app.models.user.count email: req.body.email
    .then (x)-> res.send isValid: x is 0

app.post '/api/users/api/validate', (req, res) ->
  app.models.user.validateAPI req.body.key, req.body.vCode
    .then (x) -> res.send isValid: x
    .catch () -> res.send isValid: false

app.get '*', (req, res) ->
  res.sendFile 'index.html', root: clientPath

app.use (err, req, res, next) ->
  res.status err.status or 500
  res.send message: err.message, error: err

module.exports = app