fs = require "fs"
path = require "path"
Area = require("./area.coffee").Area

world_file = path.join App.root, "game", "world.json"

class World
   constructor: ->
      @events = {}
      @areas = {}
      this.loadData()

   on: (event, callback) ->
      (@events[event] ||= []).push(callback)

# private methods
   notifyEvent: (event) ->
      callback() for callback in (@events[event] || [])

   find: (area_id) ->
      @areas[area_id]
   
   loadData: ->
      fs.readFile world_file, (err, data) =>
         throw err if err
         
         for own id, area_data of JSON.parse(data).world
            @areas[id] = new Area(area_data)

         this.notifyEvent "loaded"

World.instance = ->
   return World.__instance ||= new World()

exports.World = World.instance()