# set up  some constants for use in the global scope
global.App = 
   root: __dirname
   port: process.env.PORT || 8080

# load in our core extensions
#require("./assets/javascripts/core_extensions.coffee")

# load in libraries used in this server
game         = require("./lib/game")
EventManager = require("./lib/event_manager").EventManager

# assign the development environment if undefined
process.env.NODE_ENV ||= "development"

# log the current environment
console.log "starting up in #{process.env.NODE_ENV} mode"

# set up an event manager to manage the loading process
startup_manager = new EventManager

startup_manager.add game.World, "loaded"

# when completed loading start up the server
startup_manager.complete ->
   console.log "loading complete, starting server"
   
   server = new game.Server

   console.log("server started, view at http://127.0.0.1:#{server.port}/")