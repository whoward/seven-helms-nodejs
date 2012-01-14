http   = require "http"
path   = require "path"
static = require "node-static"
io     = require "socket.io"
Client = require("./client").Client
Connection = require("./connection").Connection
Instance = require("./instance").Instance

class exports.Server
   constructor: (port) ->
      @port = port || App.port
      @clients = []
      @instances = []

      @lobby_instance = this.create_instance()
      @lobby_instance.add_observer(this)

      # create a http server to manage delivering the static assets for
      # the web client from the "static" directory
      @static_server = new static.Server(path.join App.root, "static")

      
      @http_server = http.createServer (req, resp) =>
         # when the request has completed then serve static content
         req.addListener "end", =>
            @static_server.serve req, resp

      @http_server.listen(@port)

      # create a web socket server to piggy back on the http server and
      # respond to created web socket connections
      @socket_server = io.listen(@http_server)

      @socket_server.sockets.on "connection", (socket) =>
         this.create_client(new Connection(socket))

   create_instance: ->
      instance = new Instance

      @instances.push(instance)

      instance

   create_client: (connection) ->
      client = new Client(connection, this)
      client.instance = @lobby_instance
      
      client.add_observer(this)
      
      @clients.push(client)

      client
   
   client_disconnected: (client) ->
      this.remove_client(client)
      client.remove_observer(this)

   player_joined_instance: (instance, player) ->
      if instance is @lobby_instance
         player.login_required()

   player_left_instance: (instance, player) ->
      # do nothing

   broadcast: (message) ->
      @socket_server.sockets.emit "message", 
         type: "Broadcast"
         message: message

   broadcast_from_user: (sender, message) ->
      @socket_server.sockets.emit "talk",
         sender: sender,
         message: message

   user_list: ->
      result = []

      guest_count = 0
      
      for client in @clients
         if client.username
            result.push(client.username)
         else
            guest_count += 1

      result.push("#{guest_count} guests") if guest_count > 0

      result

   pm: (sender, recipient_name, message) ->
      recipient = null

      for client in @clients
         if client.username is recipient_name
            recipient = client
            break

      if recipient
         recipient.connection.private_message sender.username, message
      else
         sender.connection.error "PrivateMessageError", "No logged in user found named '#{recipient_name}'"

   remove_client: (client) ->
      index = @clients.indexOf(client)
      if index >= 0
         @clients.splice index, 1