

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

      # and display a friendly message about help
      this.coloredMessage "golden-yellow", "type /help for commands"

   clearInput: ->
      this.setInputText ""
   
   setInputText: (text) ->
      @input_text = text
      @input.html "> #{@input_text}_"

   appendMessage: (message) ->
      @messages.append "<li>#{message.h()}</li>"

   appendInput: (chars) ->
      this.setInputText @input_text + chars

   submitInput: ->
      input_parser.process_input(@input_text)      
      this.clearInput()

   privateMessageReceived: (sender, message) ->
      this.appendMessage "<span class='pm'>From (<a href='#'>#{sender}</a>): #{message}</span>".safe()
      
      @messages.children("li:last a").click =>
         console.log "clicked pm link"
         this.setInputText "/say #{sender} "
         false

   backspace: ->
      this.setInputText @input_text[0..-2]

   coloredMessage: (colorClass, message) ->
      this.appendMessage "<span class='bold #{colorClass.h()}'>#{message.h()}</span>".safe()

   displayArea: (area) ->
      exit_count = (dir for dir, name of area.exits).length

      @messages.append "<li class='area-header'>#{area.name.h()}</li>"
      
      this.appendMessage area.description.h()

      if area.people.length > 1
         this.coloredMessage "cyan", "There are #{area.people.length} people here: #{area.people.join(", ")}"
      else
         this.coloredMessage "cyan", "Nobody is here except you."

      this.coloredMessage "purple", "There are #{exit_count} obvious exits:"

      for dir, name of area.exits
         this.coloredMessage "purple", "\t#{dir}: #{name}"
