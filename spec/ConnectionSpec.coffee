TestSocket = require("./support/test_socket.coffee").TestSocket
Connection = require("../lib/game/connection.coffee").Connection
Area       = require("../lib/game/area.coffee").Area

describe "Connection", ->
   con = null
   socket = null

   beforeEach ->
      socket = new TestSocket()
      con = new Connection(socket)
      
   it "should emit a message given the correct arguments", ->
      con.message "TestMessage", "Hello World"

      expect(socket.emissions).toEqual [["message", {type: "TestMessage", message: "Hello World"}]]

   it "should emit a error given the correct arguments", ->
      con.error "LoginFailure", "Invalid credentials"

      expect(socket.emissions).toEqual [["error", {type: "LoginFailure", message: "Invalid credentials"}]]

   it "should send a private message given the correct arguments", ->
      con.private_message "Will", "Sup guy?"

      expect(socket.emissions.length).toEqual 1

      expect(socket.emissions[0]).toEqual ["pm", {sender: "Will", message: "Sup guy?"}]

   it "should send a list of users", ->
      con.user_list ["Will", "Foo"]

      expect(socket.emissions.length).toEqual 1
      expect(socket.emissions[0]).toEqual ["list", {users: ["Will", "Foo"]}]

   it "should send an area to the user", ->
      area = new Area
         id: "1-01"
         name: "Encampment"
         description: "Hello World!"
         exits:
            north: "1-02"

      con.send_area(area)

      expect(socket.emissions.length).toEqual 1

      emission = socket.emissions[0]

      expect(emission.length).toEqual 2

      [type, data] = emission

      expect(type).toEqual "area"
      expect(data).toEqual
         name: "[1-01] Encampment"
         description: "Hello World!"
         exits:
            north: "[Undefined Area: 1-02]"
         people: []