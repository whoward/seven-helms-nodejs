Class = require '../lib/class.coffee'


describe 'Class', ->
   it "should provide access to the global object", ->
      expected = global
      actual = Class.getGlobalObject()

      expect(actual).toEqual(expected)

   it "should allow listing all instance variables for a json object", ->
      object =
         foo: "abc"
         bar: "def"
         baz: "ghi"

      actual = Class.instanceVariables(object)

      expect(actual).toEqual ["foo", "bar", "baz"]
   
   it "should allow listing all instance variables of a class", ->
      klass = ->
         @foo = "abc"
         @bar = "def"
         @baz = "ghi"
      
      klass.hello = ->
         #foo

      klass.world = ->
         #bar
      
      klass.pi = 3.14159

      classVariables = Class.instanceVariables(klass)
      instanceVariables = Class.instanceVariables(new klass())

      expect(classVariables).toEqual ["pi"]
      expect(instanceVariables).toEqual ["foo", "bar", "baz"]

   it "should list methods of an object", ->
      class Klass
         foo: ->
            #foo
         bar: ->
            #bar
         baz: ->
            #baz
      
      Klass.hello = ->
         #abc
      
      Klass.world = ->
         #def

      classMethods = Class.instanceMethods(Klass)
      instanceMethods = Class.instanceMethods(new Klass())

      expect(classMethods).toEqual ["hello", "world"]
      expect(instanceMethods).toEqual ["foo", "bar", "baz"]

   it "should allow mixing of one class into another", ->
      class MyModule
         hello: ->
            # foo

      MyModule.__mixing = (base) ->
         # bar

      MyModule.__mixed = (base) ->
         # baz

      spyOn MyModule, '__mixing'
      spyOn MyModule, '__mixed'

      Class.mixin(Array, MyModule)

      expect(MyModule.__mixing).toHaveBeenCalledWith(Array)
      expect(MyModule.__mixed).toHaveBeenCalledWith(Array)

      expect(Array.prototype.hello).toBeAFunction()