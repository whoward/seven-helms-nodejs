World = require("./world.coffee").World

UsernameRegex = /^[A-Za-z0-9\_\-]+$/

class Client
   constructor: (connection, server) ->
      @connection = connection
      @server = server

      @username = ""
      @area_id = "1-01"

      @connection.emit "message", "Please enter a user name ..."

      @connection.on "message", (message) =>
         this.processMessage(message)

      @connection.on "command", (command, params) =>
         this.processCommand(command, params)

      @connection.on "disconnect", =>
         this.processDisconnect()

   setUsername: (username) ->
      if @server.user_list().indexOf(username) >= 0
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

   setArea: (area_id) ->
      area = World.areas[area_id]

      throw "area #{area_id} does not exist" unless area?

      @area_id = area_id

      @connection.emit "area", area.to_json()

   move: (direction) ->
      area = World.areas[@area_id]

      if not area.exits[direction]
         @connection.emit "error", "You cannot go in that direction"
         return

      this.setArea area.exits[direction]

   processMessage: (message) ->
      if not @username
         this.setUsername(message)
         this.setArea("1-01")
      else
         @server.broadcast "#{@username}: #{message}"

   processCommand: (command, params) ->
      switch command
         when "pm" then @server.pm params.username, "#{@username} says: #{params.message}"
         when "rename" then this.setUsername(params.username)
         when "list" then @connection.emit "list", @server.user_list()
         when "go" then this.move params.direction

   processDisconnect: ->
      @server.broadcast "#{@username} has left the zone."
      @server.removeClient(this)



exports.Client = Client