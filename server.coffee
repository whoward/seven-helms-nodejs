require "sugar"

# set up  some constants for use in the global scope
global.App = 
   root: __dirname
   port: process.env.PORT || 3000
   environment: process.env.NODE_ENV || "development"
   design_documents: require("./db/design_documents.coffee").DesignDocuments
   salt: require("./salt").salt

   strings:
      welcome_message: "Welcome to Seven Helms, please log in or register a new account."

# load in some stuff
EventManager = require("./lib/event_manager").EventManager
glob = require("glob")

# load in our core extensions
require("./assets/javascripts/core_extensions.coffee")

# load in the framework classes
glob.globSync("framework/*.{coffee,js}").forEach (file) ->
   require("./#{file}")

# load up all of the models under the "db" directory, they'll in turn register
# themselves as models and create appropriate design documents
glob.globSync("db/*.{coffee,js}").forEach (file) ->
   require("./#{file}")

# load in systems used in this server
game    = require("./lib/game")
couchdb = require("./lib/database.coffee").couchdb

# log the current environment
console.log "starting up in #{App.environment} mode"

# set up an event manager to manage the loading process
startup_manager = new EventManager

startup_manager.add game.World, "loaded"

startup_manager.add couchdb, "initialized"

# when completed loading start up the server
startup_manager.complete ->
   console.log "loading complete, starting server"
   
   server = new game.Server

   console.log("server started, view at http://127.0.0.1:#{server.port}/")

# and commence the whole process
couchdb.initialize()
game.World.initialize()