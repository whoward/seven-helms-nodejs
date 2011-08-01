require 'rubygems'
require 'bundler'
require 'yaml'
require 'erb'

require 'coffee_script'
require 'sass'
require 'json'

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

      packages.each do |package, files|
         puts "packaging #{package}"

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

         hash = Digest::SHA1.hexdigest(content)

         extension = File.extname(package)
         basename = File.basename(package, extension)
         

         filenames[package] = "#{basename}-#{hash}#{extension}"

         full_path = File.expand_path("static/#{filenames[package]}", File.dirname(__FILE__))

         puts "output to: #{filenames[package]}"

         open(full_path, "w+") {|f| f.write(content) }

         puts ""
      end

      puts "writing index.html"
      
      input_file = File.expand_path("assets/index.html.erb", File.dirname(__FILE__))
      output_file = File.expand_path("static/index.html", File.dirname(__FILE__))

      open(output_file, "w+") << ERB.new(File.read(input_file)).result(binding)

   end
end
