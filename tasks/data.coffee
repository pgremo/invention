module.exports = (gulp, opts) ->
  request = require 'request'
  rp = require 'request-promise'
  cheerio = require 'cheerio'
  minimist = require 'minimist'
  semver = require 'semver'
  download = require 'gulp-download'
  bzip2 = require 'decompress-bzip2'
  vinylAssign = require 'vinyl-assign'
  fs = require 'fs'

  knownOptions = string: 'eveRelease'

  options = minimist process.argv.slice(2), knownOptions

  opts.sdeSource = 'https://www.fuzzwork.co.uk/dump'

  fromString = (filename, string) ->
    src = require('stream').Readable(objectMode: true)
    src._read = ->
      @push new (gutil.File)(
        cwd: ''
        base: ''
        path: filename
        contents: new Buffer(string))
      @push null
    src

  gulp.task 'eveSDEVersion', () ->
    rp opts.sdeSource
      .promise()
      .then (body) ->
        $ = cheerio.load body
        items = $('a').map (i, item) ->
            $(this).attr 'href'
          .get()
          .filter (x) ->
            x.match "^(#{options.eveRelease}-.*)/"
          .map (x) ->
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
        console.log "Current SDE is #{opts.eveRelease}-#{opts.eveVersion}"
      .catch (err) ->
        gulp.err err

  gulp.task 'downloadSDE', ['eveSDEVersion'], () ->
    for file in ['blueprints.yaml', 'eve.db']
      if not fs.existsSync "data/#{opts.eveRelease}/#{opts.eveVersion}/#{file}"
        download "#{opts.sdeSource}/#{opts.eveRelease}-#{opts.eveVersion}/#{file}.bz2"
        .pipe vinylAssign extract: true
        .pipe bzip2()
        .pipe gulp.dest "data/#{opts.eveRelease}/#{opts.eveVersion}"
