module.exports = (gulp, opts) ->
  request = require 'request'
  rp = require 'request-promise'
  cheerio = require 'cheerio'
  minimist = require 'minimist'
  semver = require 'semver'
  bzip2 = require 'decompress-bzip2'
  vinylAssign = require 'vinyl-assign'
  through = require 'through2'
  path = require 'path'
  fs = require 'fs'
  print = require 'gulp-print'
  filter = require 'gulp-filter'
  gutil = require 'gulp-util'
  request = require 'request'
  ProgressBar = require 'progress'
  S = require 'string'
  col = gutil.colors

  knownOptions = string: 'eveRelease'

  options = minimist process.argv.slice(2), knownOptions

  opts.sdeSource = 'https://www.fuzzwork.co.uk/dump'

  gulp.task 'eveSDEVersion', () ->
    rp opts.sdeSource
      .promise()
      .then (body) ->
        $ = cheerio.load body
        items = $('a')
          .map (i, item) ->
            $(this).attr 'href'
          .get()
          .filter (x) ->
            x.match "^#{options.eveRelease}-.*/"
        if items.length is 0
          throw new Error("Eve release #{options.eveRelease} not found")
        items = items.map (x) ->
            x.slice(0, -1).split('-', 2)
          .map (x) ->
            v = x[1].split '.'
            if v.length < 3
              v = v.concat(['0', '0', '0'])[0..3]
            [x[0], x[1], v.join('.')]
        items = items.sort (a, b) ->
          semver.rcompare a[2], b[2]

        opts.eveRelease = items[0][0]
        opts.eveVersion = items[0][1]
        gutil.log "Current SDE is #{opts.eveRelease}-#{opts.eveVersion}"

  files = () ->
    stream = through.obj()
    Array::slice.call(arguments).forEach (file) -> stream.write new gutil.File(path: file)
    stream.end()
    stream

  downloadFile = (urlf) ->
    through.obj (file, enc, cb) ->
      firstLog = true
      url = urlf file

      downloadHandler = (err, res, body) =>
        fileName = url.split('/').pop();
        @push new gutil.File {path:fileName, contents: new Buffer(body)}
        cb()

      bar = undefined

      request({url: url, encoding: null}, downloadHandler)
      .on 'response', (response) ->
        len = parseInt response.headers['content-length'], 10
        fileName = S(file.path).padRight(41).truncate(41)
        bar = new ProgressBar("  downloading #{fileName} [:bar] :percent :etas", {
          complete: '=',
          incomplete: ' ',
          width: 20,
          total: len})
      .on 'data', (chunk) ->
        bar.tick chunk.length

  gulp.task 'downloadSDE', ['eveSDEVersion'], () ->
    files 'blueprints.yaml', 'eve.db'
      .pipe filter (file) -> not fs.existsSync "data/#{opts.eveRelease}/#{opts.eveVersion}/#{file.path}"
      .pipe downloadFile (file) -> "#{opts.sdeSource}/#{opts.eveRelease}-#{opts.eveVersion}/#{file.path}.bz2"
      .pipe vinylAssign extract: true
      .pipe bzip2()
      .pipe gulp.dest "data/#{opts.eveRelease}/#{opts.eveVersion}"
