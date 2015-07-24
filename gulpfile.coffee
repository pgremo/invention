gulp = require 'gulp'
mocha = require 'gulp-mocha'
coffeelint = require 'gulp-coffeelint'
nodemon = require 'gulp-nodemon'
gutil = require 'gulp-util'
rename = require 'gulp-rename'
umd = require 'gulp-umd'

opts = {}

require('./tasks/data')(gulp, opts)
require('./tasks/sql2json')(gulp, opts)
require('./tasks/yaml2json')(gulp, opts)

onError = (err) ->
  console.log err.toString()
  this.emit 'end'

gulp.task 'lint',() ->
  gulp.src ['./app/**/*.coffee', './client/**/*.coffee', './tasks/**/*.coffee', './test/**/*.coffee', 'gulpfile.coffee']
    .pipe coffeelint().on 'error', onError
    .pipe coffeelint.reporter()

gulp.task 'mocha',() ->
  gulp.src ['./test/**/*.coffee']
    .pipe mocha(reporter: 'spec').on 'error', onError

gulp.task 'server', ['build'],  ->
  nodemon
    script: './bin/www.coffee'
    nodeArgs: ['--debug']
    env:
      NODE_ENV: 'development'
      DEBUG: 'container'
      EVEONLINE_CLIENT_ID: 'cabc40b7353a42d5ac55b42f52416596'
      EVEONLINE_SECRET_KEY: 'vx3FowaRzWxtXn9Uyx9f1HbrLNfCe5j9U98AHIh3'
      TOKEN_SECRET: 'PTaYmFCeiogCmpz7.W7KLt]kCFBJNebG'
      SESSION_SECRET: 'MVfdRZoETCmcVq3BhQA?wssdk7mA=sAq'
      MONGOHQ_URL: 'mongodb://localhost/invention/sessions'
    watch:
      './app/'
  .on 'start', () ->
    console.log """
        Starting up context, serving on [localhost:#{process.env.PORT or 3000}]
        Hit CTRL-C to stop the server
      """
  .on 'quit', () ->
    console.log 'App has quit'
  .on 'restart', (files) ->
    console.log "App restarted due to: #{files}"

gulp.task 'build', ['lint', 'mocha']

gulp.task 'data', ['blueprints2json', 'types2json', 'regions2json', 'locations2json', 'stations2json', 'reactions2json', 'schematics2json']

gulp.task 'default', ['build']
