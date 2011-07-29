http   = require "http"
path   = require "path"
static = require "node-static"
io     = require "socket.io"
Client = require("./client.coffee").Client

class Server
   constructor: ->
      @clients = []
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
         @clients.push new Client(connection, this)

   broadcast: (message) ->
      @socket_server.sockets.emit("message", message)

   pm: (username, message) ->
      client = null

      for c in @clients
         if c.username == username
            client = c
            break

      return if not client?

      client.connection.emit "message", message

exports.Server = Server