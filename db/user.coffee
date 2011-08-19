Digest = require("hashlib")
CouchModel = require("../lib/couch_model").CouchModel

User = CouchModel.design "user",
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
            @hashed_password = Digest.sha1(password + @username + App.salt)
      }
   ]

   validations:
      "username":
         presence: true
         format: /^[A-Za-z0-9\_\-]+$/

      "hashed_password":
         presence: true


User.find_for_credentials = (username, password, callback) ->
   hashed_password = Digest.sha1(password + username + App.salt)

   userKey = "#{username}-#{hashed_password}"

   User.view "credentials", {key: userKey}, (users) =>
      if users.length is 0
         callback(null)
      else
         callback(users[0])

User.register = (username, password, callback) ->
   new_user = new User
      username: username
      password: password

   if not new_user.validate()
      callback("The parameters supplied are invalid")
      return

   # check to see if the user already exists
   User.view "all", {key: username}, (users) =>
      if users.length is 0
         new_user.save(callback)
      else
         callback("The username '#{username}' is already taken")

exports.User = User