require 'rubygems'
require 'bundler'
require 'yaml'

Bundler.require(:default)

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

      packages.each do |package, files|
         puts "packaging #{package}"
         package_file = File.expand_path("static/#{package}", File.dirname(__FILE__))

         package_fh = open(package_file, "w+")

         files.each do |file|
            filename = File.expand_path("assets/#{file}", File.dirname(__FILE__))

            puts "...bundle #{file}"

            case File.extname(file)
               when ".js", ".css"
                  package_fh << File.read(filename)

               when ".coffee"
                  package_fh << ::CoffeeScript.compile(File.read(filename))

               when ".sass", ".scss"
                  package_fh << Sass.compile_file(filename)

               else raise "dont know how to bundle file #{file}"
            end
         end

         puts ""
         
         package_fh.close
      end
   end
end