ModelDefinition = require('../lib/model/definition.coffee').ModelDefinition

describe 'ModelDefinition', ->
   def = null

   beforeEach ->
      def = new ModelDefinition()

   it "should allow defining an attribute", ->
      def.defineAttribute "MyAttr", 
         readable: true,
         writeable: false
      
      expect(def.attributes["MyAttr"]).toEqual
         readable: true,
         writeable: false

   it "should provide default params", ->
      def.defineAttribute "MyAttr"
      
      expect(def.attributes["MyAttr"]).toEqual
         readable: true
         writeable: true

   it "should not allow redefining an attribute", ->
      def.defineAttribute "MyAttr"

      expect(-> def.defineAttribute "MyAttr").toThrow("already defined: MyAttr")

   it "should provide a method to retrieve an attributes definition, regardless to its type", ->
      def.defineAttribute "Foo",
         save: true
         readable: true
         writeable: false

      expect(def.getAttributeDefinition("Foo")).toEqual
         save: true
         readable: true
         writeable: false
   
   it "should provide a method to see if an attribute is already defined", ->
      def.defineAttribute "Foo"

      expect(def.isAttributeDefined "Foo").toBe(true)
      expect(def.isAttributeDefined "Bar").toBe(false)

   it "should allow defining a computed attribute", ->
      def.defineAttribute "MyAttr"

      def.defineComputedAttribute "FooBar",
         dependents: ["MyAttr"]

      expect(def.computedAttributes["FooBar"]).toEqual
         dependents: ["MyAttr"]
         readable: false
         writeable: false

   it "should raise an exception if trying to redefine an existing attribute", ->
      def.defineAttribute "MyAttr"

      expect(-> def.defineComputedAttribute "MyAttr", {dependents: ["Foo"]}).toThrow("already defined: MyAttr")

   it "should raise an exception if trying to redefine an existing computed attribute", ->
      def.defineAttribute "MyAttr"
      def.defineComputedAttribute "FooBar"
         dependents: ["MyAttr"]

      expect(-> def.defineComputedAttribute "FooBar", {dependents: ["MyAttr"]}).toThrow("already defined: FooBar")

   it "should raise an exception if the required field 'dependents' is not provided", ->
      expect(-> def.defineComputedAttribute "FooBar").toThrow("dependents are required")

   it "should set the readable property if the getter property is a function", ->
      def.defineComputedAttribute "Foo",
         dependents: ["MyAttr"]
         getter: ->
            # foo

      def.defineComputedAttribute "Bar",
         dependents: ["MyAttr"]

      expect(def.computedAttributes["Foo"].readable).toBe(true)
      expect(def.computedAttributes["Bar"].readable).toBe(false)

   it "should set the writeable property if the setter property is a function", ->
      def.defineComputedAttribute "Foo",
         dependents: ["MyAttr"]
         setter: (x) ->
            # foo
      
      def.defineComputedAttribute "Bar",
         dependents: ["MyAttr"]

      expect(def.computedAttributes["Foo"].writeable).toBe(true)
      expect(def.computedAttributes["Bar"].writeable).toBe(false)

   it "should provide a list of all attributes defined", ->
      def.defineAttribute "MyAttr"

      def.defineComputedAttribute "Foo"
         dependents: ["MyAttr"]

      expect(def.getAttributeNames()).toEqual ["MyAttr", "Foo"]

   it "should provide a list of all attributes computed attributes are dependent upon", ->
      def.defineAttribute "FirstName"
      def.defineAttribute "LastName"
      def.defineAttribute "Salutation"

      def.defineComputedAttribute "FullName",
         dependents: ["FirstName", "LastName"]

      def.defineComputedAttribute "ShortenedName",
         dependents: ["LastName", "Salutation"]

      expect(def.getComputedAttributeDependents()).toEqual ["FirstName", "LastName", "Salutation"]

   it "should provide a list of all computed attributes dependent upon a given attribute", ->
      def.defineAttribute "FirstName"
      def.defineAttribute "LastName"

      def.defineComputedAttribute "FullName",
         dependents: ["FirstName", "LastName"]

      def.defineComputedAttribute "ShortenedName",
         dependents: ["LastName", "Salutation"]
   
      expect(def.getAttributesDependentOn("FirstName")).toEqual ["FullName"]
      expect(def.getAttributesDependentOn("LastName")).toEqual ["FullName", "ShortenedName"]