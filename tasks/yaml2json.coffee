gulp = require 'gulp'
map = require 'map-stream'
yaml = require 'js-yaml'
gutil = require 'gulp-util'

gulp.task 'blueprints2json', ->
  gulp.src ['data/rhea/*.yml', 'data/rhea/*.yaml']
  .pipe map (file, cb) ->
    if file.isNull() then return cb null, file
    if file.isStream() then return cb new Error 'Streaming not supported'

    json = null
    try
      json = yaml.load String file.contents.toString 'utf8'
    catch e
      console.log e
      console.log json

    file.path = gutil.replaceExtension file.path, '.json'
    file.contents = new Buffer JSON.stringify json, null, 2

    cb null,file
  .pipe gulp.dest 'app/data'
