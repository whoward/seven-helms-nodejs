class exports.Area
   constructor: (data) ->
      @id = data.id
      @name = data.name
      @description = data.description
      @exits = data.exits

   exits_to_json: ->
      World = require("./world.coffee").World

      result = {}

      for own direction, id of @exits
         area = World.areas[id]
         result[direction] = if area then area.name else "[Undefined Area: #{id}]"

      result

   to_json: ->
      name: "[#{@id}] #{@name}"
      description: @description
      exits: this.exits_to_json()