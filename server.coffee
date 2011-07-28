global.App = 
   root: __dirname
   port: 8080

World        = require("game").World
EventManager = require("event_manager").EventManager
http         = require "http"
static       = require "node-static"
socketIO     = require "socket.io"

startup_manager = new EventManager

startup_manager.add World.instance(), "loaded"

startup_manager.complete ->
   console.log "finished initial startup process, starting server"
   
   clientFiles = new static.Server "./static"

   httpServer = http.createServer (req, resp) ->
      req.addListener "end", ->
         clientFiles.serve req, resp

   httpServer.listen(App.port)

   webSocket = socketIO.listen(httpServer)

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

   console.log("server started, view at http://127.0.0.1:#{App.port}/")