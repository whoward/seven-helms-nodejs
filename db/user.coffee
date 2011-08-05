Model = require("./model").Model
Digest = require("hashlib")

class User extends Model
   constructor: (params) ->
      super(params)

Model.computedAttribute User, "id",
   save: true
   dependents: ['username']
   getter: ->
      "user-#{this.get("username")}"

Model.attribute User, "username",
   save: true

Model.attribute User, "password",
   save: false

Model.computedAttribute User, "hashed_password",
   save: true
   dependents: ['password', 'username']
   getter: ->
      # we'll use the username as our password salt and SHA1 the whole thing
      Digest.sha1(this.get("password") + this.get("username"))

exports.User = User