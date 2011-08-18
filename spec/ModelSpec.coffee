Class = require("lib/class.coffee")
Model = require("lib/model/model.coffee").Model
ModelDefinition = require("lib/model/definition.coffee").ModelDefinition

describe "Model", ->
   MyModel = null
   model = null

   beforeEach ->
      Model.__definitions = {}

      MyModel = ->
         Class.constructMixins(this)
         return this

      Class.mixin(MyModel, Model)

      Model.attribute MyModel, "ID",
         readable: true
         writeable: false

      Model.attribute MyModel, "Password",
         readable: false
         writeable: true

      Model.attribute MyModel, "MyAttr",
         readable: true
         writeable: true
         saveable: false

      Model.computedAttribute MyModel, "MyAttr2",
         dependents: ["MyAttr"],
         getter: ->
            "#{this.get("MyAttr")} FOO"

      Model.computedAttribute MyModel, "MyAttr3",
         dependents: ["MyAttr"],
         setter: (x) ->
            this.set("MyAttr", x + " FOO")

      model = new MyModel()

   it "should provide accessors for the attributes", ->
      expect(model.get "MyAttr").toBeUndefined()

      model.set "MyAttr", "SomeValue"

      expect(model.get "MyAttr").toEqual "SomeValue"

   it "should raise an error if the attribute is undefined", ->
      expect(-> model.get("Foo")).toThrow "undefined attribute: Foo"
      expect(-> model.set("Foo", "bar")).toThrow "undefined attribute: Foo"

   it "should raise an error if the attribute is not readable (when getting)", ->
      expect(-> model.get("Password")).toThrow "attribute 'Password' is not readable"

   it "should raise an error if the attribute is not writeable (when setting)", ->
      expect(-> model.set("ID", "foo")).toThrow "attribute 'ID' is not writeable"

   it "should call the getter function when retrieving a computed value", ->
      model.set("MyAttr", "Hello")
      expect(model.get("MyAttr2")).toEqual "Hello FOO"

   it "should call the setter function when setting a computed value", ->
      model.set("MyAttr3", "Hello")
      expect(model.get("MyAttr")).toEqual "Hello FOO"

   it "should provide a method to access to model definition", ->
      expect(model.getDefinition().constructor).toBe ModelDefinition

   it "should provide a method to access an attribute definition", ->
      def = model.getAttributeDefinition("MyAttr")
      cdef = model.getAttributeDefinition("MyAttr2")

      expect(def.readable).toBe true
      expect(def.writeable).toBe true
      expect(def.saveable).toBe false

      expect(cdef.readable).toBe true
      expect(cdef.writeable).toBe false
      expect(cdef.dependents).toEqual ["MyAttr"]

   it "should provide a method to mass assign values without raising errors", ->
      attributes =
         ID: 35
         Password: "foobar"
         MyAttr: "hello_world"
         MyAttr2: "blah"

      expect(model.massAssignValues(attributes)).not.toThrow

      expect(model.__retrieveValue("ID")).toBeUndefined()
      expect(model.__retrieveValue("Password")).toEqual "foobar"
      expect(model.__retrieveValue("MyAttr")).toEqual "hello_world"

   if "function" is typeof Object.prototype.__defineGetter__
      it "should define native javascript getters and setters for attributes with readable/writeable set properly", ->
         expect(model.__lookupGetter__("ID")).toBeAFunction()
         expect(model.__lookupSetter__("ID")).toBeUndefined()

         expect(model.__lookupGetter__("Password")).toBeUndefined()
         expect(model.__lookupSetter__("Password")).toBeAFunction()
         

   it "should allow adding an observer, which is notified before and after an attribute update", ->
      observer =
         attributeValueWillChange: ->
            # foo
         attributeValueDidChange: ->
            # bar

      spyOn observer, "attributeValueWillChange"
      spyOn observer, "attributeValueDidChange"

      model.addObserver("MyAttr", observer)

      expect(observer.attributeValueWillChange).not.toHaveBeenCalled()
      expect(observer.attributeValueDidChange).not.toHaveBeenCalled()

      model.set("MyAttr", "Foo")

      expect(observer.attributeValueWillChange).toHaveBeenCalledWith "MyAttr"
      expect(observer.attributeValueDidChange).toHaveBeenCalledWith "MyAttr"

   it "should raise an error if trying to add an observer to an undefined attribute", ->
      expect(-> model.addObserver("Foo", {})).toThrow "undefined attribute: Foo"

   it "should raise an error if trying to add an observer to a non-readable attribute", ->
      expect(-> model.addObserver("Password", {})).toThrow "attribute 'Password' is not readable"

   it "should notify observers of a computed attribute when one of it's dependents are updated", ->
      observer =
         attributeValueWillChange: ->
            # foo
         attributeValueDidChange: ->
            # bar

      spyOn observer, "attributeValueWillChange"
      spyOn observer, "attributeValueDidChange"

      model.addObserver("MyAttr2", observer)

      model.set("MyAttr", "Hello")

      expect(observer.attributeValueWillChange).toHaveBeenCalledWith "MyAttr2"
      expect(observer.attributeValueDidChange).toHaveBeenCalledWith "MyAttr2"