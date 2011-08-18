Class = require("lib/class")
Model = require("lib/model/model").Model

FunctionValidator = require("./function_validator").FunctionValidator
PresenceValidator = require("./presence_validator").PresenceValidator
FormatValidator = require("./format_validator").FormatValidator

class ValidatableModel
   validate: ->
      validators = (this.getDefinition().__validators || [])

      for validator in validators
         return false if not validator.validate(this)

      true

ValidatableModel.__mixed = (base) ->
   Class.mixin(base, Model)
   Model.getModelDefinition(base).__validators = []

ValidatableModel.validate = ->
   if arguments.length < 2
      throw "at least two arguments are required"

   model = arguments[0]

   unless model.__modules and model.__modules.indexOf(ValidatableModel) >= 0
      throw "object must implement validatable model module"

   validators = Model.getModelDefinition(model).__validators

   # if given a string as the only argument then add it as a function validator
   if arguments.length is 2 and "string" is typeof arguments[1]
      validators.push(new FunctionValidator(arguments[1]))

   if arguments.length is 3 
      attribute = arguments[1]
      options = arguments[2]

      for own validator_type, param of options
         builder = ValidatableModel.validators[validator_type]

         continue if not builder

         validator = builder(attribute, param)

         continue if not validator

         validators.push(validator)

ValidatableModel.validators = 
   "presence": (attribute, validate_presence) ->
      if validate_presence
         return new PresenceValidator(attribute)
      else
         return null

   "format": (attribute, regex) ->
      return new FormatValidator(attribute, regex)

   

exports.ValidatableModel = ValidatableModel