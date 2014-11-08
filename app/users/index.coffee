neow = require 'neow'

module.exports =
  identity: 'user'
  connection: 'invention'
  autoPK: false
  attributes:
    id:
      type: 'integer'
      primaryKey: true
      required: true
    name:
      type: 'string'
    key:
      type: 'string'
    vCode:
      type: 'string'
#  beforeValidate: (values, next) ->
#    validateAPI values.key, values.vCode
#      .then (x) ->
#        if x then next()
#        else
#          error = new Error 'Invalid Key and or vCode'
#          error.status = 400
#          next error
#      .catch () ->
#        error = new Error 'Invalid Key and or vCode'
#        error.status = 400
#        next error
#  validateAPI: (key, vCode) ->
#    client = new neow.EveClient keyID: key, vCode: vCode
#    client
#      .fetch 'account:APIKeyInfo'
#      .then (x) ->
#        (parseInt(x.key.accessMask) & 2) is 2 and x.key.type is 'Account'
