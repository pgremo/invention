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
  beforeValidate: (values, next) ->
    client = new neow.EveClient keyID: values.key, vCode: values.vCode
    client
      .fetch 'account:APIKeyInfo'
      .then (x) ->
        if (parseInt(x.key.accessMask) & 2) is 2 and x.key.type is 'Account'
          next()
        else
          error = new Error 'Invalid Key and or vCode'
          error.status = 400
          next error
      .catch (x) ->
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
