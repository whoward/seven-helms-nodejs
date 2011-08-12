CouchModel = require("../lib/couch_model").CouchModel
ValidatableModel = require("../lib/validatable_model/model").ValidatableModel
Model = require("../lib/model/model").Model

describe "Couch Model", ->
   User = null
   def = null

   beforeEach ->
      Model.__definitions = {}

      User = CouchModel.design
         attributes: [
            {name: "id", saveable: false},
            {name: "first_name"},
            {name: "last_name"}
         ],
         computed_attributes: [
            {
               name: "full_name",
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
      expect(def.getAttributeNames()).toEqual ["id", "first_name", "last_name", "full_name"]
      expect(def.attributes.id.saveable).toBe false

   it "should define all validations when designing", ->
      expect(def.__validators.length).toEqual 5

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