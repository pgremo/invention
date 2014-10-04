passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
User = require '../users'

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

exports.initialize = passport.initialize()
exports.session = passport.session()
exports.handler = passport.authenticate 'local',
  successRedirect: '/'
  failureRedirect: '/#/login'
  failureFlash: true
