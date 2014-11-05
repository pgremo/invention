uuid = require 'node-uuid'
neow = require 'neow'
bcrypt = require 'bcrypt'

module.exports =
  identity: 'user'
  connection: 'invention'
  attributes:
    email:
      type: 'email'
      required: true
      unique: true
    password:
      type: 'string'
      required: true
    key:
      type: 'string'
      required: true
    vCode:
      type: 'string'
      required: true
    toJSON: () ->
      email: @email
      key: @key
      vCode: @vCode
  beforeValidate: (values, next) ->
    validateAPI values.key, values.vCode
      .then (x) ->
        if x then next()
        else
          error = new Error 'Invalid Key and or vCode'
          error.status = 400
          next error
      .catch () ->
        error = new Error 'Invalid Key and or vCode'
        error.status = 400
        next error
  beforeCreate: [
    (values, next) ->
      values.id = uuid.v4()
      next()
    ,
    (values, next) ->
      bcrypt.hash values.password, 10, (err, hash) ->
        if err? then return next(err)
        values.password = hash
        next()
    ]
  validateAPI: (key, vCode) ->
    client = new neow.EveClient keyID: key, vCode: vCode
    client
      .fetch 'account:APIKeyInfo'
      .then (x) ->
        (parseInt(x.key.accessMask) & 2) is 2 and x.key.type is 'Account'
