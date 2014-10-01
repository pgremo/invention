mongoose = require 'mongoose'
uuid = require 'node-uuid'

url = 'mongodb://localhost/invention'

userSchema = mongoose.Schema
  _id:
    type: String
    default: () -> uuid.v4()
  email: String
  password: String

userSchema.methods.validPassword = (password) -> this.password is password

User = mongoose.model 'users', userSchema

mongoose.connect url
mongoose.connection.on 'error', (err) -> console.log err
mongoose.connection.on 'connected', () -> console.log "connected to #{url}"

module.exports = User
