UsernameRegex = /^[A-Za-z0-9\_\-]+$/

class Client
   constructor: (connection, server) ->
      @connection = connection
      @server = server

      @username = ""

      @connection.emit "message", "Please enter a user name ..."

      @connection.on "message", (message) =>
         this.processMessage(message)

      @connection.on "command", (command, params) =>
         this.processCommand(command, params)

      @connection.on "disconnect", =>
         this.processDisconnect()

   setUsername: (username) ->
      if @server.user_list().contains username
         @connection.emit "message", "Sorry, that username is already in use"

      else if UsernameRegex.test(username || "")
         # if already defined then this is a rename
         if @username
            @server.broadcast "#{@username} is now known as #{username}"
         else
            @server.broadcast "#{username} has entered the zone."

         @username = username

      else
         @connection.emit "message", "Please only use letters, numbers, underscores (_) and hyphens (-)"

   processMessage: (message) ->
      if not @username
         this.setUsername(message) 
      else
         @server.broadcast "#{@username}: #{message}"

   processCommand: (command, params) ->
      switch command
         when "pm" then @server.pm params.username, "#{@username} says: #{params.message}"
         when "rename" then this.setUsername(params.username)
         when "list" then @connection.emit "list", @server.user_list()

   processDisconnect: ->
      @server.broadcast "#{@username} has left the zone."
      @server.removeClient(this)



exports.Client = Client