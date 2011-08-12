
class exports.FormatValidator
   constructor: (attribute, regex) ->
      @attribute = attribute
      @regex = regex

   validate: (model) ->
      @regex.test(model.get(@attribute))