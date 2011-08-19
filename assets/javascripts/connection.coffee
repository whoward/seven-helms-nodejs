
class window.Connection
   constructor: ->
      @socket = io.connect()

      @socket.on "connect", ->
         game_screen.coloredMessage "red", "Connected to the server."

      @socket.on "message", (message) =>
         this.processMessage(message.type, message.message)

      @socket.on "pm", (sender, message) ->
         game_screen.privateMessageReceived sender, message

      @socket.on "list", (playerList) ->
         game_screen.coloredMessage "blue", "Users: #{playerList.join(", ")}"

      @socket.on "area", (areaData) ->
         game_screen.displayArea(areaData)

      @socket.on "error", (error) =>
         this.processError(error.type, error.message)

      @socket.on "disconnect", ->
         game_screen.coloredMessage "red", "Disconnected from the server."

   login: (name, password) ->
      this.command "login"
         username: name
         password: md5(password)

   register: (name, password) ->
      this.command "register"
         username: name
         password: md5(password)

   pm: (name, msg) ->
      this.command "pm"
         username: name
         message: msg

   list: ->
      this.command "list"

   go: (dir) ->
      this.command "go"
         direction: dir
# private
   message: (message) ->
      @socket.emit "message", message

   command: (command, params) ->
      @socket.emit "command", command, params

   processMessage: (type, message) ->
      switch type
         when "LoginRequired"
            game_screen.appendMessage(message)
            login_dialog.show()

         when "LoginSuccess"
            game_screen.appendMessage(message)
            login_dialog.hide()

         when "RegistrationSuccess"
            game_screen.appendMessage(message)
            registration_dialog.hide()

         else
            game_screen.appendMessage(message)

   processError: (type, message) ->
      switch type
         when "LoginFailure" then alert(message)
         when "RegistrationFailure" then alert(message)
         else
            game_screen.coloredMessage "purple", message