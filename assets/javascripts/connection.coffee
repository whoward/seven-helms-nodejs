
class window.Connection
   constructor: ->
      @socket = io.connect()

      @socket.on "connect", ->
         game_screen.coloredMessage "red", "Connected to the server."

      @socket.on "message", (message) ->
         game_screen.appendMessage(message)

      @socket.on "disconnect", ->
         game_screen.coloredMessage "red", "Disconnected from the server."

   message: (message) ->
      @socket.emit "message", message

   command: (command, params) ->
      @socket.emit "command", command, params

   pm: (name, msg) ->
      this.command "pm"
         username: name
         message: msg

   rename: (name) ->
      this.command "rename"
         username: name