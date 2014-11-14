gulp = require 'gulp'
mocha = require 'gulp-mocha'
coffeelint = require 'gulp-coffeelint'
nodemon = require 'gulp-nodemon'
gutil = require 'gulp-util'
rename = require 'gulp-rename'
requireDir = require 'require-dir'
umd = require 'gulp-umd'

dir = requireDir 'tasks'

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
    nodeArgs: ['--nodejs', '--debug']
    env:
      NODE_ENV: 'development'
      DEBUG: 'container'
      EVEONLINE_SECRET_KEY: 'UspiFh6xharsVGctAXhMf6LD)YfCh(ZK'
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

gulp.task 'default', ['build']
