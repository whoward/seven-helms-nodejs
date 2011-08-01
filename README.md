# What is this?

This is a Node.JS server and HTML/JavaScript client for a MUD engine I'm writing to redo an old "Choose your own adventure" type BASIC project I wrote back in my first year of high school.  

The writing is horrible and well deserved of an adolescent (hopefully we'll one day mature that part) - but the game should still be somewhat entertaining.

The server and client are written mostly in CoffeeScript, since I generally like it better than JavaScript and I needed practice in it.  The HTML client uses WebSockets, because they're cool.  It should run well on most modern browsers (IE9, Firefox, Chrome, Safari) but I'm sure there bugs (please, feel free to submit any to the Issues page - otherwise there's a good chance I won't notice them and thus not fix them)

# How to Install

1. Install Node.JS: [here](https://github.com/joyent/node/wiki/Installation)
2. Install Node Package Manager: [here](http://npmjs.org/)
3. Install Node Packages: ``` npm install . ```
4. Install Ruby-based build tools: ``` apt-get install rubygems; gem install bundler; bundle install ```
5. Compile everything: ``` rake compile ```

# How to run

Development: ```coffee server.coffee```

Production: ```node boot-production.js```