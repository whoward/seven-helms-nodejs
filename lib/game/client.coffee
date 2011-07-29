class Client
   constructor: (connection, server) ->
      console.log("new connection!")
      @connection = connection
      @server = server

      @username = ""

      @connection.emit "message", "Please enter a user name ..."

      @connection.on "message", (message) =>
         this.processMessage(message)

      @connection.on "disconnect", =>
         this.processDisconnect()

   processMessage: (message) ->
      if !@username
         @username = message
         @server.broadcast "#{@username} has entered the zone."
         return
      
      if message.indexOf("/say ") is 0
         words = message.split(/\s+/)
         user = words[1]
         message = words[2..-1].join(" ")

         @server.pm user, "#{@username} says: #{message}"
      else
         @server.broadcast "#{@username}: #{message}"

   processDisconnect: ->
      @server.broadcast "#{@username} has left the zone."

exports.Client = Client