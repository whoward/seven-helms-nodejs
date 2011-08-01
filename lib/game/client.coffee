World = require("./world.coffee").World

UsernameRegex = /^[A-Za-z0-9\_\-]+$/

class Client
   constructor: (connection, server) ->
      @connection = connection
      @server = server

      @username = ""
      @area_id = ""

      @connection.emit "message", "Please enter a user name ..."

      @connection.on "message", (message) =>
         this.process_message(message)

      @connection.on "command", (command, params) =>
         this.process_command(command, params)

      @connection.on "disconnect", =>
         this.process_disconnect()

   set_username: (username) ->
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

   get_area: ->
      World.find(@area_id)

   set_area: (next_area) ->
      current_area = this.get_area()

      @area_id = next_area.id

      if current_area
         current_area.remove_player(this)

      next_area.add_player(this)

      @connection.emit "area", next_area.to_json()

   move: (direction) ->
      current_area = this.get_area()
      next_area = current_area.area_for_direction(direction)

      if not next_area
         @connection.emit "error", "You cannot go in that direction"
         return

      this.set_area(next_area)

      if current_area
         current_area.notify_exit(this, direction)
         next_area.notify_entrance(this, current_area, direction)
      
   notify_entrance: (player, direction) ->
      if direction
         @connection.emit "message", "#{player.username} has arrived from the #{direction} direction"
      else
         @connection.emit "message", "#{player.username} has entered the area"

   notify_exit: (player, direction) ->
      @connection.emit "message", "#{player.username} has left the area in the #{direction} direction"

   process_message: (message) ->
      if not @username
         this.set_username(message)
         this.set_area(World.find("1-01"))
      else
         @server.broadcast "#{@username}: #{message}"

   process_command: (command, params) ->
      switch command
         when "pm" then @server.pm params.username, "#{@username} says: #{params.message}"
         when "rename" then this.set_username(params.username)
         when "list" then @connection.emit "list", @server.user_list()
         when "go" then this.move params.direction

   process_disconnect: ->
      @server.broadcast "#{@username} has left the zone."
      @server.removeClient(this)



exports.Client = Client