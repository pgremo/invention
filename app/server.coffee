express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
bodyParser = require 'body-parser'
logger = require 'morgan'
routes = require './routes'

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
User = require './users'

passport.use new LocalStrategy {usernameField: 'email', passwordField: 'password'}, (email, password, done) ->
  User.findOne {email: email}, (err, user) ->
    switch
      when err then done err
      when !user then done null, false, message: 'Incorrect email.'
      else user.checkEncrypted 'password', password, (err, isMatch) ->
        switch
          when err then done err
          when isMatch then done null, user
          else done null, false, message: 'Invalid password'

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  User.findById id, (err, user) ->
    done err, user

app = express()

app.use logger 'combined'
app.use favicon path.join __dirname, '..', 'client', 'favicon.ico'
app.use logger 'dev'
app.use express.static path.join __dirname, '..', 'client'
app.use require('cookie-parser')()
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true
app.use require('express-session') secret: 'hullaballoo', resave: true, saveUninitialized: true
app.use require('flash')()
app.use passport.initialize()
app.use passport.session()

app.use '/', routes

app.post '/login',
  passport.authenticate 'local',
    successRedirect: '/'
    failureRedirect: '/login.html'
    failureFlash: true

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
  console.log err
  res.status err.status or 500
  res.send if app.get('env') is 'development' then err else {}

module.exports = app