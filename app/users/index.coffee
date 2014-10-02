mongoose = require 'mongoose'
uuid = require 'node-uuid'
mongooseEncrypted = require('mongoose-encrypted').loadTypes mongoose
encryptedPlugin = mongooseEncrypted.plugins.encryptedPlugin
Encrypted = mongoose.SchemaTypes.Encrypted

saltWorkFactor = 10
url = process.env.MONGOHQ_URL or 'mongodb://localhost/invention'

userSchema = mongoose.Schema
  _id:
    type: String
    default: () -> uuid.v4()
  email:
    type: String
    required: true
    unique: true
    index: true
  password:
    type: Encrypted
    method: 'bcrypt'
    encryptOptions:
      saltRounds: saltWorkFactor
      seedLength: 20
  key:
    type: String
    required: true
  vCode:
    type: String
    required: true

userSchema.plugin encryptedPlugin

User = mongoose.model 'users', userSchema

mongoose.connect url
mongoose.connection.on 'error', (err) -> console.log err
mongoose.connection.on 'connected', () -> console.log 'connected'

module.exports = User
