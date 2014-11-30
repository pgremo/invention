Promise = require 'bluebird'
fs = require 'fs'

Promise.promisifyAll fs

loadFile = (file) ->
  fs.readFileAsync file, 'utf8'
  .then JSON.parse

exports.locations = loadFile './app/data/locations.json'
exports.stations = loadFile './app/data/stations.json'
exports.regions = loadFile './app/data/regions.json'
exports.blueprints = loadFile './app/data/blueprints.json'
exports.reactions = loadFile './app/data/reactions.json'
exports.schematics = loadFile './app/data/schematics.json'
exports.types = loadFile './app/data/types.json'