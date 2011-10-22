fs = require "fs"
path = require "path"
EventEmitter = require("events").EventEmitter
Area = require("./area").Area

class World extends EventEmitter
   constructor: ->
      super

      @areas = {}

   initialize: ->
      world_file = path.join App.root, "game", "world.json"
      
      fs.readFile world_file, (err, data) =>
         throw err if err
         
         for own id, area_data of JSON.parse(data).world
            @areas[id] = new Area(area_data)

         this.emit "loaded"

   find: (area_id) ->
      @areas[area_id]

World.instance = ->
   return World.__instance ||= new World()

exports.World = World.instance()