
class exports.TestSocket
   constructor: ->
      @emissions = []

   emit: ->
      @emissions.push Array::slice.call(arguments)