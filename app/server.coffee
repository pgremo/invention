express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
bodyParser = require 'body-parser'
logger = require 'morgan'
routes = require './routes'

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
User = require './users'

passport.use new LocalStrategy (username, password, done) ->
  User.findOne {email: username}, (err, user) ->
    switch
      when err then done err
      when !user then done null, false, message: 'Incorrect username.'
      when !user.validPassword password then done null, false, message: 'Incorrect password.'
      else done null, user

app = express()

app.use favicon path.join __dirname, '..', 'client', 'favicon.ico'
app.use logger 'dev'
app.use express.static path.join __dirname, '..', 'client'
app.use require('cookie-parser')()
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true
app.use require('express-session')(secret: 'hullaballoo', resave: true, saveUninitialized: true)
app.use require('flash')()
app.use passport.initialize()
app.use passport.session()

app.use '/', routes

app.post '/login',
  passport.authenticate 'local',
    successRedirect: '/'
    failureRedirect: '/login.html'
    failureFlash: true

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