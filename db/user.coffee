Model = require("./model").Model

class User extends Model
   constructor: (params) ->
      super(params)

Model.define User, "id"
Model.define User, "username"
Model.define User, "hashed_password"

exports.User = User