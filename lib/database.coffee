cradle       = require("cradle")
EventEmitter = require("events").EventEmitter

class Database extends EventEmitter
   initialize: ->
      @database_name = "seven-helms-#{App.environment}"

      @design_document_is_stale = {}

      @con = @connection = new (cradle.Connection)()

      @db = @con.database(@database_name)

      # start by checking that the database exists already, if not create it
      @db.exists (err, database_exists) =>
         throw err if err

         if not database_exists
            this.create_database()
         else
            this.database_created()

   get: ->
      @db.get.apply(@db, arguments)
   
   view: ->
      @db.view.apply(@db, arguments)

   save: ->
      @db.save.apply(@db, arguments)

   merge: ->
      @db.merge.apply(@db, arguments)

   remove: ->
      @db.remove.apply(@db, arguments)

# private   
   create_database: ->
      console.log "creating couchdb database: #{@database_name}"
      @db.create (err, result) =>
         throw err if err
         
         console.log "database created: ", result

         this.database_created()

   database_created: ->
      for own name, schema of App.design_documents
         this.check_staleness_of_design_document(name, schema)

   check_staleness_of_design_document: (name, schema) ->

      # check if the design document exists, if not create it
      @db.get "_design/#{name}", (error, doc) =>
         @design_document_is_stale[name] = error or doc.version isnt schema.version

         if @design_document_is_stale[name]
            this.save_design_document(name, schema, doc)
         else
            this.design_document_saved()
            
   save_design_document: (name, schema, existing_document) ->
      verb = if existing_document then "updat" else "creat"

      console.log "#{verb}ing design document: ", name

      callback = (error, result) =>
         throw error if error
         
         console.log "design document #{verb}ed: ", name

         this.design_document_saved(name)

      if existing_document
         @db.save("_design/#{name}", existing_document._rev, schema, callback)
      else
         @db.save("_design/#{name}", schema, callback)

   design_document_saved: (name) ->
      @design_document_is_stale[name] = false

      if this.stale_design_documents_count() is 0
         this.done_initialization()

   stale_design_documents_count: ->
      result = 0
      for own name, is_stale of @design_document_is_stale
         result++ if is_stale
      result

   done_initialization: ->
      this.emit "initialized"

Database.instance = ->
   Database.__instance ||= new Database()

exports.couchdb = Database.instance()