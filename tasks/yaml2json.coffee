module.exports = (gulp, opts) ->
  yaml = require 'js-yaml'
  gutil = require 'gulp-util'
  through = require 'through2'

  json = () ->
    through.obj (file, enc, cb) ->
      if file.isNull() then return cb null, file
      if file.isStream() then return cb new Error 'Streaming not supported'

      result = yaml.load String file.contents.toString 'utf8'

      file.path = gutil.replaceExtension file.path, '.json'
      file.contents = new Buffer JSON.stringify result, null, 2

      cb null, file

  gulp.task 'blueprints2json', ['downloadSDE'], ->
    gulp.src "data/#{opts.eveRelease}/#{opts.eveVersion}/blueprints.yaml"
      .pipe json()
      .pipe gulp.dest 'app/data'
