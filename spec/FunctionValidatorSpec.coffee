FunctionValidator = require("lib/validatable_model/function_validator.coffee").FunctionValidator

describe "Function Validator", ->

   it "should call the given function on the given model", ->
      model =
         hello_world: ->
            # foo

      spyOn model, "hello_world"

      validator = new FunctionValidator("hello_world")

      validator.validate(model)

      expect(model.hello_world).toHaveBeenCalled()

   it "should coerce the result to a boolean and return that", ->
      model = 
         foo: ->
            true
         bar: ->
            false
         baz: ->
            "hello"
         hello: ->
            null
         world: ->
            undefined

      valid1 = new FunctionValidator "foo"
      valid2 = new FunctionValidator "bar"
      valid3 = new FunctionValidator "baz"
      valid4 = new FunctionValidator "hello"
      valid5 = new FunctionValidator "world"

      expect(valid1.validate(model)).toBe true
      expect(valid2.validate(model)).toBe false
      expect(valid3.validate(model)).toBe true
      expect(valid4.validate(model)).toBe false
      expect(valid5.validate(model)).toBe false

   it "should raise an exception if the given function is not defined on the model", ->
      model =
         hello_world: ->
            # foo

      validator = new FunctionValidator("foo")
      
      expect(-> validator.validate(model)).toThrow "undefined function for validation: foo"