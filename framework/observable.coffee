require "./set"

class global.Observable
   @__construct = (instance) ->
      instance._observers = new Set
   
   add_observer: (observer) ->
      @_observers.add(observer)

   remove_observer: (observer) ->
      @_observers.remove(observer)

   notify_observers: (event) ->
      args = [this].concat Array::slice.call(arguments)[1..-1]

      @_observers.each (obs) ->
         obs[event].apply(obs, args) if "function" is typeof obs[event]

      null