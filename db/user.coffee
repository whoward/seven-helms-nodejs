Digest = require("hashlib")
CouchModel = require("../lib/couch_model").CouchModel

exports.User = CouchModel.design "user",
   design_version: 5

   views:
      all:
         map: (doc) ->
            return unless doc.type is "user"
            emit(doc.username, doc)

      credentials:
         map: (doc) ->
            return unless doc.type is "user"
            emit("#{doc.username}-#{doc.hashed_password}", doc)

   attributes: [
      {
         name: "username",
         save: true
      },
      {
         name: "hashed_password",
         save: true
      }
   ]

   computed_attributes: [
      {
         name: "_id"
         save: true
         dependents: ["username"]
         getter: ->
            "user-#{@username}"
      },
      {
         name: "password"
         save: false
         dependents: ["username"]
         setter: (password) ->
            @hashed_password = Digest.sha1(password + @username)
      }
   ]

   validations:
      "username":
         presence: true
         format: /^[A-Za-z0-9\_\-]+$/

      "hashed_password":
         presence: true