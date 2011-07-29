
class window.Screen
   constructor: (root) ->
      @messages = jQuery("<ul/>").attr("id", "messages").appendTo(root)
      @input = jQuery("<div/>").attr("id", "console").appendTo(root)

      this.clearInput()

   clearInput: ->
      this.setInputText ""
   
   setInputText: (text) ->
      @input_text = text
      @input.html "> #{@input_text}_"

   appendMessage: (message) ->
      @messages.append "<li>#{message}</li>"

   appendInput: (chars) ->
      this.setInputText @input_text + chars

   submitInput: ->
      connection.message(@input_text)
      this.clearInput()

   backspace: ->
      this.setInputText @input_text[0..-2]
