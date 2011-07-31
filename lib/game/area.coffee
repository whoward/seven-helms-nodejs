World = require("./world.coffee").World

class exports.Area
   constructor: (data) ->
      @id = data.id
      @name = data.name
      @description = data.description
      @exits = data.exits

      @players = []
   
   get_name: ->
      if App.environment is "production"
         return @name
      else
         return "[#{@id}] #{@name}"

   area_for_direction: (direction) ->
      World.find(@exits[direction])

   exits_json: ->
      World = require("./world.coffee").World

      result = {}

      for own direction, id of @exits
         area = World.find(id)
         if area
            result[direction] = area.get_name()
         else
            result[direction] = "[Undefined Area: #{id}]"

      result

   exit_for_id: (area_id) ->
      for own direction, id of @exits
         return direction if id is area_id

   add_player: (player) ->
      if @players.indexOf(player) == -1
         @players.push(player)
   
   remove_player: (player) ->
      index = @players.indexOf(player)
      if index >= 0
         @players.splice(index, 1)
      
   player_names: ->
      player.username for player in @players

   notify_entrance: (entering_player, previous_area, direction) ->
      matching_direction = this.exit_for_id(previous_area.id)
      for player in @players
         continue if player is entering_player
         player.notify_entrance(entering_player, matching_direction)

   notify_exit: (exiting_player, direction) ->
      for player in @players
         continue if player is exiting_player
         player.notify_exit(exiting_player, direction)

   to_json: ->
      name: @get_name()
      description: @description
      exits: @exits_json()
      people: @player_names()