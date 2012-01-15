
class Connection
   constructor: (socket) ->
      @socket = socket

   broadcast: (message) ->
      @socket.emit "message", 
         type: "Broadcast"
         message: message

   message: (type, message) ->
      @socket.emit "message",
         type: type
         message: message

   error: (type, message) ->
      @socket.emit "error",
         type: type
         message: message

   private_message: (sender, message) ->
      @socket.emit "pm",
         sender: sender
         message: message

   user_list: (users) ->
      @socket.emit "list",
         users: users

   send_area: (area) ->
      @socket.emit "area", area.to_json()

   on: ->
      @socket.on.apply(@socket, arguments)

exports.Connection = Connection