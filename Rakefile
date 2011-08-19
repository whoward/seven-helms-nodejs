require 'rubygems'
require 'bundler'
require 'yaml'
require 'erb'
require 'digest'

require 'coffee_script'
require 'sass'
require 'json'

desc "generates a new random salt (don't do this unless you really really mean it)"
task :salt do
   open("salt.js", "w+") do |file|
      random_number = Kernel.rand(10000).to_s
      salt = Digest::SHA1.hexdigest(random_number)

      file << "exports.salt = '#{salt}';"
   end
end

desc "compiles all static files"
task :compile => ["compile:world", "compile:assets"]

namespace :compile do
   desc "compiles all the world yaml files into a single world json file"
   task :world do
      print "building world file..."

      result = {}
      world = result[:world] = {}

      Dir.glob(File.expand_path("data/**/*.yml", File.dirname(__FILE__))).each do |world_file|
         data = YAML.load_file(world_file)
         world[data["id"]] = data
      end

      open("game/world.json", "w") do |file|
         file.puts result.to_json
      end

      puts "done"
   end

   desc "compiles the javascript assets into a single entry"
   task :assets do
      packages = YAML.load_file("assets.yml")

      filenames = {}

      # run through all the packages defined in the assets yaml file, concat
      # them all together into a big string then take the SHA1 hash of it to
      # generate the filename.
      packages.each do |package, files|
         puts "packaging #{package}"

         # concatenate all the files together, compiling them into the proper
         # *.js or *.css source as necessary (for CoffeeScript and Sass) 
         # respectively
         content = files.inject("") do |output, file|
            filename = File.expand_path("assets/#{file}", File.dirname(__FILE__))

            puts "...bundle #{file}"

            case File.extname(file)
               when ".js", ".css"
                  output << File.read(filename)

               when ".coffee"
                  output << ::CoffeeScript.compile(File.read(filename))

               when ".sass", ".scss"
                  output << Sass.compile_file(filename)

               else raise "dont know how to bundle file #{file}"
            end
         end

         # calculate the SHA1 hash of the contents of the file and join them
         # up to make the output filename, we append the hash to deal with issues
         # associated with client side caching (incidentially this is what 
         # Rails 3.1 does as well)
         hash = Digest::SHA1.hexdigest(content)

         extension = File.extname(package)
         basename = File.basename(package, extension)
         
         filenames[package] = "#{basename}-#{hash}#{extension}"

         # finally write the contents out to disk under the static/ directory
         full_path = File.expand_path("static/#{filenames[package]}", File.dirname(__FILE__))

         puts "output to: #{filenames[package]}"

         open(full_path, "w+") {|f| f.write(content) }

         puts ""
      end

      # and now that we've generated the assets, compile the ERB index page to
      # the static/ directory as well
      puts "writing index.html"
      
      input_file = File.expand_path("assets/index.html.erb", File.dirname(__FILE__))
      output_file = File.expand_path("static/index.html", File.dirname(__FILE__))

      open(output_file, "w+") << ERB.new(File.read(input_file)).result(binding)

   end
end