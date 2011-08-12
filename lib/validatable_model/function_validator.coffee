
class exports.FunctionValidator
   constructor: (function_name) ->
      @function_name = function_name

   validate: (model) ->
      if "function" isnt typeof model[@function_name]
         throw "undefined function for validation: #{@function_name}"

      !!(model[@function_name].call(model))