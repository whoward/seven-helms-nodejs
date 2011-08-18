
class window.Connection
   constructor: ->
      @socket = io.connect()

      @socket.on "connect", ->
         game_screen.coloredMessage "red", "Connected to the server."

      @socket.on "message", (message) ->
         game_screen.appendMessage(message)

      @socket.on "pm", (sender, message) ->
         game_screen.privateMessageReceived sender, message

      @socket.on "list", (playerList) ->
         game_screen.coloredMessage "blue", "Users: #{playerList.join(", ")}"

      @socket.on "area", (areaData) ->
         game_screen.displayArea(areaData)

      @socket.on "error", (message) ->
         game_screen.coloredMessage "purple", message

      @socket.on "disconnect", ->
         game_screen.coloredMessage "red", "Disconnected from the server."

   message: (message) ->
      @socket.emit "message", message

   command: (command, params) ->
      @socket.emit "command", command, params

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

   rename: (name) ->
      this.command "rename"
         username: name

   list: ->
      this.command "list"

   go: (dir) ->
      this.command "go"
         direction: dir