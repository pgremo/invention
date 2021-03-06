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
        items = items
          .map (x) ->
            trimmed = x.slice(0, -1).replace(/-/, ' ').split(' ')
            reformatted = trimmed[1].replace(/(-+)/, ' ').split(' ')
            v = reformatted[0].split '.'
            if v.length < 3
              v = v.concat(['0', '0', '0'])[0..2]
            [trimmed, "#{v.join('.')}-#{reformatted[1]}"]
        items = items.sort (a, b) ->
          semver.rcompare a[1], b[1]

        opts.eveRelease = items[0][0][0]
        opts.eveVersion = items[0][0][1]
        gutil.log "Current SDE is #{opts.eveRelease}-#{opts.eveVersion}"

  files = () ->
    stream = through.obj()
    Array::slice.call(arguments).forEach (file) -> stream.write new gutil.File(path: file)
    stream.end()
    stream

  downloadFile = (urlf) ->
    through.obj (file, enc, cb) ->
      url = urlf file
      gutil.log url

      downloadHandler = (err, res, body) =>
        fileName = url.split('/').pop()
        @push new gutil.File {path:fileName, contents: new Buffer(body)}
        cb()

      request({url: url, encoding: null}, downloadHandler)
      .on 'response', ->
        fileName = S(file.path).padRight(41).truncate(41)
        gutil.log "  downloading #{fileName}"

  gulp.task 'downloadSDE', ['eveSDEVersion'], () ->
    destination = "data/#{opts.eveRelease}/#{opts.eveVersion}"
    files 'blueprints.yaml', 'eve.db'
      .pipe filter (file) -> not fs.existsSync "#{destination}/#{file.path}"
      .pipe downloadFile (file) -> "#{opts.sdeSource}/#{opts.eveRelease}-#{opts.eveVersion}/#{file.path}.bz2"
      .pipe vinylAssign extract: true
      .pipe bzip2()
      .pipe gulp.dest destination
