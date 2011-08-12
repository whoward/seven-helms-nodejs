FormatValidator = require("../lib/validatable_model/format_validator").FormatValidator
Model = require("../lib/model/model").Model
Class = require("../lib/class")

describe "format validator", ->
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

      validator = new FormatValidator("name", /^[a-zA-Z]+$/)

   it "should validate an attribute value which matches the regular expression", ->
      model.name = "abcdef"

      expect(validator.validate(model)).toBe true

   it "should not match the attribute value which doesn't match the regular expression", ->
      model.name = "123456"

      expect(validator.validate(model)).toBe false