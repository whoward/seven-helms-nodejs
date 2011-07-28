http   = require "http"
path   = require "path"
static = require "node-static"
io     = require "socket.io"

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
      
      @server.broadcast "#{@username}: #{message}"

   processDisconnect: ->
      @server.broadcast "#{@username} has left the zone."

class Server
   constructor: ->
      @port = App.port

      @static_server = new static.Server(path.join App.root, "static")

      @http_server = http.createServer (req, resp) =>
         req.addListener "end", =>
            @static_server.serve req, resp

      @http_server.listen(@port)

      @socket_server = io.listen(@http_server)

      @socket_server.configure "production", =>
         console.log "removing websocket support for production =("
         @socket_server.set "transports", ["xhr-polling"]

      @socket_server.sockets.on "connection", (connection) =>
         new Client(connection, this)

   broadcast: (message) ->
      @socket_server.sockets.emit("message", message)


exports.Server = Server