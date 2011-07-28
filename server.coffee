# set up  some constants for use in the global scope
global.App = 
   root: __dirname
   port: process.env.PORT || 8080

# load in libraries used in this server
World        = require("./lib/game").World
EventManager = require("./lib/event_manager").EventManager
http         = require "http"
static       = require "node-static"
io           = require "socket.io"

# assign the development environment if undefined
process.env.NODE_ENV ||= "development"

# log the current environment
console.log "starting up in #{process.env.NODE_ENV} mode"

# set up an event manager to manage the loading process
startup_manager = new EventManager

startup_manager.add World.instance(), "loaded"

# when completed loading start up the server
startup_manager.complete ->
   console.log "loading complete, starting server"
   
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

   webSocket.configure "production", ->
      console.log "removing websocket support for production =("
      webSocket.set 'transports', ['xhr-polling']

   console.log("server started, view at http://127.0.0.1:#{App.port}/")