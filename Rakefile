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
end