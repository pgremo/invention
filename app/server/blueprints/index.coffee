yaml = require 'js-yaml'
Promise = require 'bluebird'
path = require 'path'
fs = Promise.promisifyAll require 'fs'

safeLoadAsync = (data) ->
  return new Promise (resolve, reject) ->
    try
      resolve yaml.safeLoad data
    catch e
      reject e

fileName = path.join __dirname, 'blueprints.yaml'

blueprints = fs.readFileAsync fileName, 'utf8'
  .then safeLoadAsync

exports.blueprint = (id) ->
  blueprints.then (data) ->
    data[id]

