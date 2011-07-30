CommandRegex = /^\/([A-Za-z]+)(\s+(.+))?/

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
      if match = CommandRegex.exec(@input_text)
         this.processCommand(match[1], match[3])
      else if @input_text[0] is "/"
         this.unknownCommand "Sorry, I don't understand what kind of command you're trying to do"
      else
         connection.message(@input_text)
      
      this.clearInput()

   backspace: ->
      this.setInputText @input_text[0..-2]

   processCommand: (command, text) ->
      switch command
         when "say"
            [username, message] = (/^([A-Za-z0-9\_\-]+)\s+(.+)/.exec(text) || ["", "", ""])[1..]
            if username and message
               connection.pm username, message
               this.coloredMessage "blue", "to #{username}: #{message}"
            else
               this.unknownCommand "usage: /say <username> <message>".html_escape()

         when "go" then connection.go(text)

         when "list" then connection.list()

         when "rename" then connection.rename(text)

         when "help" then this.printHelp()

         else this.unknownCommand "Sorry, I don't understand the command \"#{command}\""

   printHelp: ->
      this.coloredMessage "golden-yellow", "commands: /say /rename /help /list /go"

   unknownCommand: (message) ->
      this.coloredMessage "purple", message

   coloredMessage: (colorClass, message) ->
      this.appendMessage "<span class='bold #{colorClass.h()}'>#{message.h()}</span>".safe()

   displayArea: (area) ->
      exit_count = (dir for dir, name of area.exits).length

      @messages.append "<li class='area-header'>#{area.name.h()}</li>"
      
      this.appendMessage area.description.h()

      this.coloredMessage "purple", "There are #{exit_count} obvious exits:"

      for dir, name of area.exits
         this.coloredMessage "purple", "\t#{dir}: #{name}"
