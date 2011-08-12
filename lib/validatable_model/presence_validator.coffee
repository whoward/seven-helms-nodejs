
class exports.PresenceValidator
   constructor: (attribute) ->
      @attribute = attribute

   validate: (model) ->
      value = model.get(@attribute)

      return false if value is undefined
      return false if value is null
      return false if "string" is typeof value and value.replace(/\s+/g, '').length == 0

      true
   