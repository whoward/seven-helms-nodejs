global.App = 
   root: __dirname
   port: 8080

World        = require("game").World
EventManager = require("event_manager").EventManager
http         = require "http"
static       = require "node-static"

startup_manager = new EventManager

startup_manager.add World.instance(), "loaded"

startup_manager.complete ->
   console.log "finished initial startup process, starting server"
   
   clientFiles = new static.Server "./static"

   httpServer = http.createServer (req, resp) ->
      req.addListener "end", ->
         clientFiles.serve req, resp

   httpServer.listen(App.port)

   console.log("server started, view at http://127.0.0.1:#{App.port}/")