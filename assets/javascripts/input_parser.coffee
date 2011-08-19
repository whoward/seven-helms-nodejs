CommandRegex = /^\/([A-Za-z]+)(\s+(.+))?/

class window.InputParser

   process_input: (message) ->
      if match = CommandRegex.exec(message)
         this.processCommand(match[1], match[3])
      else if message is "/"
         game_screen.unknownCommand "Sorry, I don't understand what kind of command you're trying to do"
      else
         connection.message(message)

   processCommand: (command, text) ->
      switch command
         when "say"
            [username, message] = (/^([A-Za-z0-9\_\-]+)\s+(.+)/.exec(text) || ["", "", ""])[1..]
            if username and message
               connection.pm username, message
               game_screen.coloredMessage "blue", "to #{username}: #{message}"
            else
               this.unknownCommand "usage: /say <username> <message>".html_escape()

         when "go" then connection.go(text)

         when "list" then connection.list()

         when "help" then this.printHelp()

         else this.unknownCommand "Sorry, I don't understand the command \"#{command}\""

   printHelp: ->
      game_screen.coloredMessage "golden-yellow", "commands: /say /help /list /go"

   unknownCommand: (message) ->
      game_screen.coloredMessage "purple", message

