
class EventManager
   constructor: ->
      @remaining = 0
      @callbacks = []
   
   add: (object, event) ->
      @remaining++
      object.on event, =>
         @remaining--
         this.notifyComplete() if @remaining is 0

   complete: (callback) ->
      if @remaining is 0
         callback()
      else
         @callbacks.push callback

# private methods
   notifyComplete: ->
      callback() for callback in @callbacks


exports.EventManager = EventManager