
class window.GameScreen
   constructor: (root) ->
      # build up the console divs
      @container = jQuery("<div/>").attr("id", "container").appendTo(root)

      @messages = jQuery("<ul/>").attr("id", "messages").appendTo(@container)
      @input = jQuery("<div/>").attr("id", "console").appendTo(@container)

      # each time the viewport resizes update the height of the console container to match
      jQuery(window).resize =>
         @container.css "height", jQuery(window).height() - 20
         @container.css "width", jQuery(window).width() - 40

      jQuery(window).trigger("resize")

      # use a scroll pane (regulated by jQuery) to display the console
      @container.jScrollPane
         maintainPosition: true
         stickToBottom: true
         animateScroll: true
         enableKeyboardNavigation: false
         autoReinitialise: true
         autoReinitialiseDelay: 500

      # and display the console input
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
