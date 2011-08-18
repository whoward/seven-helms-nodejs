http   = require "http"
path   = require "path"
static = require "node-static"
io     = require "socket.io"
Client = require("./client").Client

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

      @socket_server.sockets.on "connection", (connection) =>
         @clients.push new Client(connection, this)

   broadcast: (message) ->
      @socket_server.sockets.emit("message", message)

   user_list: ->
      result = []

      guest_count = 0
      
      for c in @clients
         if c.username
            result.push(c.username)
         else
            guest_count += 1

      result.push("#{guest_count} guests") if guest_count > 0

      result

   pm: (username, message) ->
      client = null

      for c in @clients
         if c.username == username
            client = c
            break

      return if not client?

      client.connection.emit "pm", message

   removeClient: (client) ->
      index = @clients.indexOf(client)
      if index >= 0
         @clients.splice index, 1

exports.Server = Server