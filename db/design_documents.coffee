
exports.DesignDocuments = {}

exports.DesignDocuments["seven-helms"] =
   version: 2
   validate_doc_update: (doc, prev_doc, user_context) ->
      # if being deleted the new doc should not equal the previous doc
      return if doc._deleted

      # all documents must have the type attribute
      throw "type is required" if not doc.type

exports.DesignDocuments["users"] = 
   version: 2
   views:
      users:
         map: (doc) ->
            emit(doc.username, doc) if doc.type is "user"
      credentials:
         map: (doc) ->
            emit("#{doc.username}-#{doc.hashed_password}", doc) if doc.type is "user"            

   validate_doc_update: (doc, prev_doc, user_context) ->
      return unless doc.type is "user"
      
      throw "id format is incorrect" unless doc._id is "user-#{doc.username}"
      throw "username is required" unless doc.username
      throw "password is required" unless doc.hashed_password
      throw "username format is incorrect" unless /^[A-Za-z0-9\_\-]+$/.test(doc.username)