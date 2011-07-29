fs = require "fs"
path = require "path"

world_file = path.join App.root, "game", "world.json"

class World
   constructor: ->
      @events = {}
      this.loadData()

   on: (event, callback) ->
      (@events[event] ||= []).push(callback)

# private methods
   notifyEvent: (event) ->
      callback() for callback in (@events[event] || [])

   
   loadData: ->
      fs.readFile world_file, (err, data) =>
         throw err if err
         
         @data = JSON.parse(data)

         this.notifyEvent "loaded"
         

World.instance = ->
   return World.__instance ||= new World()

exports.World = World.instance()