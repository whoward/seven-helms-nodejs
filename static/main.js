$(document).ready(function() {
    var webSocket = io.connect('http://' + window.location.host);

    webSocket.on('connect', function() {
        $('#messages').append('<li>Connected to the server.</li>');
    });

    webSocket.on('message', function(message) {
        $('#messages').append('<li>' + message + '</li>');
    });

    webSocket.on('disconnect', function() {
        $('#messages').append('<li>Disconnected from the server.</li>');
    });

    $('#sendButton').bind('click', function() {
        var message = $('#messageText').val();
        webSocket.emit("message", message);
        $('#messageText').val('');
    });

    $("#messageText").bind("keypress", function(e) {
       var code = (e.keyCode ? e.keyCode : e.which);
       if(code === 13) {
           $("#sendButton").click();
       }
    });
});
