
class exports.Instance extends BasicObject
   constructor: ->
      Kernel.construct_mixins(this)

      @players = new Set

   add_player: (player) ->
      if @players.add player
         this.notify_observers "player_joined_instance", player

   remove_player: (player) ->
      if @players.remove player
         this.notify_observers "player_left_instance", player
   
   broadcast: (message) ->
      @players.each (player) ->
         player.broadcast(message)

Kernel.mixin(exports.Instance, Observable)