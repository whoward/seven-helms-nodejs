global.App = 
   root: __dirname
   port: process.env.PORT || 8080

World        = require("./lib/game").World
EventManager = require("./lib/event_manager").EventManager
http         = require "http"
static       = require "node-static"
io           = require "socket.io"

console.log "process.env.NODE_ENV is:", process.env.NODE_ENV

startup_manager = new EventManager

startup_manager.add World.instance(), "loaded"

startup_manager.complete ->
   console.log "finished initial startup process, starting server"
   
   clientFiles = new static.Server "./static"

   httpServer = http.createServer (req, resp) ->
      req.addListener "end", ->
         clientFiles.serve req, resp

   httpServer.listen(App.port)

   webSocket = io.listen(httpServer)

   webSocket.sockets.on "connection", (client) ->
      client.emit "message", "Please enter a user name ..."

      userName = ""
      client.on "message", (message) ->
         if !userName
            userName = message
            webSocket.sockets.emit "message", message + " has entered the zone."
            return

         webSocket.sockets.emit "message", userName + ": " + message
      
      client.on "disconnect", ->
         webSocket.sockets.emit "message", userName + " has left the zone."

   webSocket.configure ->
     webSocket.set 'transports', ['xhr-polling']

   console.log("server started, view at http://127.0.0.1:#{App.port}/")