World = require("./world").World
User = require("../../db/user").User

class Client
   constructor: (connection, server) ->
      @connection = connection
      @server = server

      @area_id = ""
      @user = null

      # display the connection message (currently hardcoded, later will be customizable)
      @connection.emit "message", 
         type: "LoginRequired"
         message: "Welcome to Seven Helms, please log in or register a new account."

      # handle basic messages from the client
      @connection.on "message", (message) =>
         this.process_message(message)

      # handles command messages from the client
      @connection.on "command", (command, params) =>
         this.process_command(command, params)

      # handles disconnect messages from the client
      @connection.on "disconnect", =>
         this.process_disconnect()

      # since its used so often define a getter for the username
      this.__defineGetter__ "username", ->
         if @user and @user.username
            return @user.username
         else
            return null

   ###
      Retrieves the area the player is currently placed in
   ###
   get_area: ->
      World.find(@area_id)

   ###
      Moves the player from the current area to the given area, removing 
      references to them as necessary.  Also sends the next area's information
      to the player.
   ###
   set_area: (next_area) ->
      current_area = this.get_area()

      @area_id = next_area.id

      if current_area
         current_area.remove_player(this)

      next_area.add_player(this)

      @connection.emit "area", next_area.to_json()

   ###
      Moves the player in the given direction name.  If the direction is not
      defined then an error message will be displayed to the player.
   ###
   move: (direction) ->
      current_area = this.get_area()
      next_area = current_area.area_for_direction(direction)

      if not next_area
         @connection.emit "error", 
            type: "UndefinedDirection"
            message: "You cannot go in that direction"
         return

      this.set_area(next_area)

      if current_area
         current_area.notify_exit(this, direction)
         next_area.notify_entrance(this, current_area, direction)

   ###
      Determines if the params given identify the user as a valid user that
      already exists.  If identified the user will be logged in, otherwise they
      will be displayed an error message.

      When logged in the user will be set up in the initial area.  This is
      temporary as we will actually delegate this part to the game script later.
   ###
   login: (params) ->
      unless params.username and params.password
         @connection.emit "error"
            type: "LoginFailure"
            message: "Please provide both a username and password"
         return

      if @server.user_list().indexOf(params.username) >= 0
         @connection.emit "error", 
            type: "LoginFailure"
            message: "That user account is already in use (maybe a bad thing?)"
         return

      User.find_for_credentials params.username, params.password, (user) =>
         if not user
            @connection.emit "error", 
               type: "LoginFailure"
               message: "Login error: no matching credentials for the username/password you provided"
         else
            @connection.emit "message"
               type: "LoginSuccess"
               message: "You have successfully logged in, welcome!"
            
            @server.broadcast "#{user.username} has logged on"

            @user = user

            this.set_area(World.find("1-01"))

   ###
      Registers the given user so long as the given parameters are valid.  If
      the registration proceeds smoothly then the user is immediately logged in.

      For now, no spam detection is done, we'll just trust our users to be good.
   ###
   register: (params) ->
      unless params.username and params.password
         @connection.emit "error", 
            type: "RegistrationFailure"
            message: "Please provide both a username and password"
         return

      User.register params.username, params.password, (error, user) =>
         if error
            @connection.emit "error",
               type: "RegistrationFailure"
               message: error
            return

         @connection.emit "message", 
            type: "RegistrationSuccess"
            message: "You have successfully registered! now logging you in."

         this.login(params)
      
   ###
      This send a message to the player letting them know a player has entered 
      the current area.  The direction they entered from will be displayed if 
      the exit is bi-directional.
   ###
   notify_entrance: (player, direction) ->
      if direction
         @connection.emit "message", 
            type: "Notification"
            message: "#{player.username} has arrived from the #{direction} direction"
      else
         @connection.emit "message",
            type: "Notification"
            message: "#{player.username} has entered the area"
   
   ###
      This sends a message to the player letting them know a player has left the
      current area in the given direction
   ###
   notify_exit: (player, direction) ->
      @connection.emit "message", 
         type: "Notification"
         message: "#{player.username} has left the area in the #{direction} direction"

   ###
      This function sends a message back to the client saying they must login,
      usually called when the user isn't logged in and tries to do anything
      but login or register
   ###
   not_logged_in: ->
      @connection.emit "error", 
         type: "LoginRequired"
         message: "You are not logged in, please log in."

   ###
      Sends a message back saying the client is already logged in.  Usually used
      when the user attempts 
   ###
   already_logged_in: ->
      @connection.emit "error", 
         type: "LogoutRequired"
         message: "You are already logged in, please log out before attempting this."

   ###
      Processes a regular non-command message from the client, this will mean
      that they are sending a message to their instance.  If the client has not
      yet logged in then we display an error message and do nothing else.
   ###
   process_message: (message) ->
      if not @user
         this.not_logged_in()
      else
         @server.broadcast "#{@username}: #{message}"

   ###
      Processes a command message from the client, based on the command parameter
      different behavior will occur.  If the user is not yet logged in and is
      not attempting to login and register an error message will be displayed.
   ###
   process_command: (command, params) ->
      if not @user and command isnt "login" and command isnt "register"
         this.not_logged_in()
         return

      if @user and (command is "login" or command is "register")
         this.already_logged_in()
         return
      
      switch command
         when "pm" then @server.pm this, params.username, params.message
         when "list" then @connection.emit "list", @server.user_list()
         when "go" then this.move params.direction
         when "login" then this.login(params)
         when "register" then this.register(params)

   process_disconnect: ->
      current_area = this.get_area()
      if current_area
         current_area.remove_player(this)

      # if already logged in then broadcast a message saying they've disconnected
      if @user
         @server.broadcast "#{@user.username} has logged off."

      @server.removeClient(this)




exports.Client = Client