require 'rubygems'
require 'yaml'
require 'json'

namespace :compile do
   desc "compiles all the world yaml files into a single world json file"
   task :world do
      result = {}
      world = result[:world] = {}

      Dir.glob(File.expand_path("data/**/*.yml", File.dirname(__FILE__))).each do |world_file|
         data = YAML.load_file(world_file)
         world[data["id"]] = data
      end

      open("game/world.json", "w") do |file|
         file.puts result.to_json
      end
   end

   desc "compiles the javascript assets into a single entry"
   task :assets do
      packages = YAML.load_file("assets.yml")

      packages.each do |package, files|
         puts "packaging #{package}"
         package_file = File.expand_path("static/#{package}.js", File.dirname(__FILE__))

         package_fh = open(package_file, "w+")

         files.each do |file|
            filename = File.expand_path("assets/#{file}", File.dirname(__FILE__))

            puts "...bundle #{file}"

            case File.extname(filename)
               when ".js"
                  package_fh << File.read(filename)

               when ".coffee"
                  package_fh << `coffee -cs < #{filename}`

               else raise "dont know how to bundle file #{file}"
            end
         end

         package_fh.close
      end
   end
end