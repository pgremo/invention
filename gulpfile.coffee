gulp = require 'gulp'
mocha = require 'gulp-mocha'
coffeelint = require 'gulp-coffeelint'
nodemon = require 'gulp-nodemon'
browserify = require 'gulp-browserify'
gutil = require 'gulp-util'
rename = require 'gulp-rename'
requireDir = require 'require-dir'
stylus = require 'gulp-stylus'
dir = requireDir 'tasks'

onError = (err) ->
  console.log err.toString()
  this.emit 'end'

gulp.task 'lint',() ->
  gulp.src ['./app/**/*.coffee', './client/**/*.coffee', './test/**/*.coffee', 'gulpfile.coffee']
    .pipe coffeelint().on 'error', onError
    .pipe coffeelint.reporter()

gulp.task 'mocha',() ->
  gulp.src ['./test/**/*.coffee']
    .pipe mocha(reporter: 'spec').on 'error', onError

gulp.task 'coffee', () ->
  gulp.src './client/invention/invention.coffee', read: false
    .pipe browserify
      transform: ['coffeeify']
      extensions: ['.coffee']
      debug: true
    .pipe rename 'invention.js'
    .pipe gulp.dest './client/invention'

gulp.task 'stylus', () ->
  gulp.src './client/invention/invention.styl'
    .pipe stylus
      sourcemap:
        inline: true,
        sourceRoot: '..',
        basePath: 'css'
    .pipe gulp.dest './client/invention'

gulp.task 'server', ['build', 'watch'],  ->
  nodemon
    script: './bin/www.coffee'
    nodeArgs: ['--nodejs', '--debug']
    env:
      NODE_ENV: 'development'
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

gulp.task 'watch', () ->
  gulp.watch ['./client/**/*.coffee'], ['coffee']
  gulp.watch ['./client/**/*.styl'], ['stylus']

gulp.task 'build', ['lint', 'mocha', 'coffee', 'stylus']

gulp.task 'default', ['build']
