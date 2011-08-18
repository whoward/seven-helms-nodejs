CouchModel = require("../lib/couch_model").CouchModel
ValidatableModel = require("../lib/validatable_model/model").ValidatableModel
Model = require("../lib/model/model").Model

describe "Couch Model", ->
   User = null
   def = null

   beforeEach ->
      Model.__definitions = {}

      User = CouchModel.design "user",
         design_version: 1
         attributes: [
            {
               name: "id",
               save: false
            },
            {
               name: "first_name",
               save: true
            },
            {
               name: "last_name",
               save: true
            }
         ],
         computed_attributes: [
            {
               name: "full_name",
               save: false,
               dependents: ["first_name", "last_name"],
               getter: ->
                  "#{@first_name} #{@last_name}"
            }
         ],
         validations: {
            "full_name_is_unique": true
            "first_name": {
               presence: true,
               format: /[a-zA-Z]+/
            },
            "last_name": {
               presence: true,
               format: /[a-zA-Z]+/
            }
         }
      
      User::full_name_is_unique = ->
         true

      def = Model.getModelDefinition(User)   

   it "should subclass the CouchModel class when being designed", ->
      expect(User).toBeAFunction()
      expect(User.__super__).toBeDefined()
      expect(User.__super__).toEqual(CouchModel.prototype)

   it "should mix in the validatable model and model mixins when designing", ->
      expect(User.__modules).toContain(ValidatableModel)
      expect(User.__modules).toContain(Model)

   it "should define all attributes given when designing", ->
      names = def.getAttributeNames()

      expect(names.length).toBe 7

      expect(names).toInclude "_id"
      expect(names).toInclude "_rev"
      expect(names).toInclude "id"
      expect(names).toInclude "type"
      expect(names).toInclude "first_name"
      expect(names).toInclude "last_name"
      expect(names).toInclude "full_name"
      
      expect(def.attributes.id.save).toBe false

   it "should define all validations when designing", ->
      expect(def.__validators.length).toEqual 5
   
   it "should define the type on the model when designing", ->
      expect(User.model_type).toEqual "user"
   
   it "should define a getter function on the model", ->
      expect(User.get).toBeAFunction()

   it "should define a view query function on the model", ->
      expect(User.view).toBeAFunction()

   it "should raise an error if the design_version is not specified", ->
      expect(-> 
         CouchModel.design "foo",
            attributes: []
            computed_attributes: []
            validations: []
      ).toThrow("design_version is required")

   it "should define the design_version on the model", ->
      expect(User.design_version).toEqual 1

   it "should install a design document", ->
      expect(App.design_documents.bar).toBeUndefined()

      CouchModel.design "bar",
         design_version: 1
         views:
            all:
               map: ->

      expect(App.design_documents.bar).toBeDefined()

      expect(App.design_documents.bar.version).toEqual 1
      expect(App.design_documents.bar.views.all.map).toBeAFunction()

   it "should mass assign given attributes", ->      
      user = new User
         first_name: "Mal"
         last_name: "Reynolds"
      
      expect(user.first_name).toEqual "Mal"
      expect(user.last_name).toEqual "Reynolds"
      expect(user.full_name).toEqual "Mal Reynolds"

   it "should be saveable", ->
      user = new User
         first_name: "Mal"
         last_name: "Reynolds"

      expect(user.save()).toBe true

   it "should not save (returning false) when the model is invalid", ->
      user = new User
         first_name: "000"
         last_name: "Reynolds"
      
      expect(user.save()).toBe false

   it "should have a method to retrieve saveable values", ->
      user = new User
         id: "my-internal-id"
         first_name: "Mal"
         last_name: "Reynolds"

      expect(user.saveable_values()).toEqual {first_name: "Mal", last_name: "Reynolds", type: "user"}