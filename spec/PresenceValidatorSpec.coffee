PresenceValidator = require("../lib/validatable_model/presence_validator").PresenceValidator
Model = require("../lib/model/model").Model
Class = require("../lib/class")

describe "presence validator", ->
   model = null
   validator = null

   beforeEach ->
      Model.__definitions = {}

      MyModel = ->
         Class.constructMixins(this)
         return this

      Class.mixin(MyModel, Model)

      Model.attribute MyModel, "name"

      model = new MyModel()

      validator = new PresenceValidator("name")

   it "should invalidate undefined values", ->
      expect(validator.validate(model)).toBe false

   it "should invalidate the value of null", ->
      model.name = null

      expect(validator.validate(model)).toBe false

   it "should invalidate empty strings", ->
      model.name = ""

      expect(validator.validate(model)).toBe false

   it "should invalidate strings containing only whitespace", ->
      model.name = "   \n\t\n   "

      expect(validator.validate(model)).toBe false

   it "should validate strings with non-whitespace length", ->
      model.name = "foo"

      expect(validator.validate(model)).toBe true