
class global.Set
   constructor: ->
      @elements = []

   add: (x) ->
      if @elements.indexOf(x) >= 0
         return false
      else
         @elements.push(x)
         return true
   
   remove: (x) ->
      idx = @elements.indexOf(x)
      if idx >= 0
         @elements.removeAt(idx)
         return true
      else
         return false

   each: ->
      Array::each.apply(@elements, arguments)