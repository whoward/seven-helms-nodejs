Class = require("../lib/class")
Model = require("../lib/model/model").Model

ValidatableModel = require("../lib/validatable_model/model").ValidatableModel
FunctionValidator = require("../lib/validatable_model/function_validator").FunctionValidator
PresenceValidator = require("../lib/validatable_model/presence_validator").PresenceValidator
FormatValidator = require("../lib/validatable_model/format_validator").FormatValidator

describe "Validatable model", ->
   MyModel = null
   model = null
   definition = null

   beforeEach ->
      Model.__definitions = {}

      MyModel = ->
         Class.constructMixins(this)
         return this

      Class.mixin(MyModel, ValidatableModel)

      Model.attribute MyModel, "name"

      model = new MyModel()

      definition = Model.getModelDefinition(MyModel)

   it "should also mix in the model class", ->
      expect(MyModel.__modules).toInclude(Model)

   it "should evaluate to true if no validations are given", ->
      expect(model.validate()).toBe(true)

   it "should evaluate to true if all validations pass", ->
      ValidatableModel.validate(MyModel, "name", {presence: true, format: /[a-z]+/})
      
      expect(model).toBeInvalid()

      model.name = "123"

      expect(model).toBeInvalid()

      model.name = "abc"

      expect(model).toBeValid()

   it "should raise an exception if < 2 args are given for the validate definition", ->
      expect(-> ValidatableModel.validate()).toThrow "at least two arguments are required"
      expect(-> ValidatableModel.validate(MyModel)).toThrow "at least two arguments are required"

   it "should raise an exception if the object doesn't mix in the validatable module", ->
      expect(-> ValidatableModel.validate("foo", "bar")).toThrow "object must implement validatable model module"

   it "should attach a function call validator to the validators list when given a string", ->
      ValidatableModel.validate(MyModel, "must_have_a_valid_username")

      expect(definition.__validators).not.toBeEmpty()
      expect(definition.__validators[0]).toBeAnInstanceOf(FunctionValidator)

   it "should attach a presence validator if given in the options hash", ->
      ValidatableModel.validate(MyModel, "name", {presence: true})

      expect(definition.__validators).not.toBeEmpty()
      expect(definition.__validators[0]).toBeAnInstanceOf(PresenceValidator)

   it "should attach a format validator if given in the options hash", ->
      ValidatableModel.validate(MyModel, "name", {format: /^\w+$/})

      expect(definition.__validators).not.toBeEmpty()
      expect(definition.__validators[0]).toBeAnInstanceOf(FormatValidator)

   