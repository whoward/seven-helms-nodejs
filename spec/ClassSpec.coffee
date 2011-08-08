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

   it "should add to the modules list when mixing", ->
      class MyModule
         hello: ->
            # foo

      class MyClass
         foo: ->
            # foo

      expect(MyClass.__modules).toBeUndefined()

      Class.mixin(MyClass, MyModule)

      expect(MyClass.__modules).toBeDefined()

      expect(MyClass.__modules[0]).toBe(MyModule)

   it "should not replace the modules list when mixing", ->
      class MyModuleA
         hello: ->
            # hello

      class MyModuleB
         world: ->
            # world
      
      class MyClass
         foo: ->
            # foo

      Class.mixin MyClass, MyModuleA
      Class.mixin MyClass, MyModuleB

      expect(MyClass.__modules.length).toEqual(2)

   it "should not mix in the same module multiple times", ->
      class MyModule
         hello: ->
            # hello

      MyModule.__mixing = ->
         # mixing
      
      MyModule.__mixed = ->
         # mixed
      
      class MyClass
         foo: ->
            # foo

      spyOn MyModule, '__mixing'
      spyOn MyModule, '__mixed'

      Class.mixin MyClass, MyModule
      Class.mixin MyClass, MyModule

      expect(MyClass.__modules.length).toEqual(1)

      expect(MyModule.__mixing.callCount).toEqual(1)
      expect(MyModule.__mixed.callCount).toEqual(1)

   it "should provide a function to call mixin 'constructors'", ->
      class MyModule
         hello: ->
            # hello
      
      MyModule.__construct = ->
         # construct

      class MyClass
         constructor: ->
            Class.constructMixins(this)

      Class.mixin MyClass, MyModule

      spyOn MyModule, '__construct'

      expect(MyModule.__construct).not.toHaveBeenCalled()

      instance = new MyClass()

      expect(MyModule.__construct).toHaveBeenCalledWith(instance)