
class window.Connection
   constructor: ->
      @socket = io.connect()

      @socket.on "connect", ->
         screen.appendMessage "Connected to the server."

      @socket.on "message", (message) ->
         screen.appendMessage(message)

      @socket.on "disconnect", ->
         screen.appendMessage "Disconnected from the server."

   message: (message) ->
      @socket.emit "message", message

   command: (command, params) ->
      @socket.emit "command", jQuery.extend(params, {"command": command})