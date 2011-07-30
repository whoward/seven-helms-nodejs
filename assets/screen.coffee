
class window.Screen
   constructor: (root) ->
      @container = jQuery("<div/>").attr("id", "container").appendTo(root)

      @messages = jQuery("<ul/>").attr("id", "messages").appendTo(container)
      @input = jQuery("<div/>").attr("id", "console").appendTo(container)

      jQuery(window).resize =>
         @container.css "height", jQuery(window).height()
         console.log jQuery(window).height()

      jQuery(window).trigger("resize")

      @container.jScrollPane
         maintainPosition: true
         stickToBottom: true
         animateScroll: true
         enableKeyboardNavigation: false
         autoReinitialise: true
         autoReinitialiseDelay: 100

      @container.data("jsp").scrollToBottom false 
      @appendMessage "scroll to bottom"

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
