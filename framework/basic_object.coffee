
#
# This is my own personal base object class which I intend to use for CoffeeScript work
# to take advantage of accessors available in the server side (since I dont care about IE6)
# and whatever modern javascript paradigms I care about
#
class global.BasicObject
   # these base getters/setters were provided by ericdiscord from github here:
   #   https://github.com/jashkenas/coffee-script/issues/1039
   #
   # thank you very much!
   @get: (propertyName, func) ->
      Object.defineProperty @::, propertyName,
         configurable: true
         enumerable: true
         get: func
   
   @set: (propertyName, func) ->
      Object.defineProperty @::, propertyName,
         configurable: true
         enumerable: true
         set: func

   # and my own personal extension of this to add some ruby-esque attribute definers
   @attr_reader: (propertyName) ->
      Object.defineProperty @::, propertyName,
         configurable: true
         enumerable: true
         get: ->
            @[propertyName]

   @attr_writer: (propertyName) ->
      Object.defineProperty @::, propertyName,
         configurable: true
         enumerable: true
         set: (x) ->
            @[propertyName] = x