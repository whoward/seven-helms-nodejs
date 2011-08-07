require 'libnotify'
require 'guard/notifier'
require 'rake'
load 'Rakefile'

ROOT = File.dirname(__FILE__)

def icon_path(name)
   "#{ROOT}/vendor/images/#{name}.png"
end

def notify(options={})
   Libnotify.new do |notify|
      notify.summary   = options[:head]
      notify.body      = options[:body]
      notify.timeout   = options.fetch(:timeout, 1.5)
      notify.urgency   = options.fetch(:urgency, :critical)
      notify.append    = options.fetch(:append, true)
      notify.icon_path = options.has_key?(:icon) ? icon_path(options[:icon]) : nil
   end.show!
end

def run_jasmine_suite
   puts "running jasmine test suite"

   regex = /(\d+) test[s]?, (\d+) assertion[s]?, (\d+) failure[s]?/

   result = `/usr/bin/env jasmine-node --coffee spec`.split(/\n/).select {|x| x =~ regex }.first

   puts "couldn't parse result =(" if not result

   all, tests, assertions, failures = regex.match(result).to_a

   result_string = "#{tests} tests, #{assertions} assertions, #{failures} failures"

   puts result_string

   icon = failures.to_i == 0 ? :success : :failed

   notify :head => "Jasmine Test Results", :body => result_string, :icon => icon
end

guard 'shell' do
   # watch for changes to the lib and spec directories and run the test suite when that happens
   watch(/spec\/(.+)/) { run_jasmine_suite }
   watch(/lib\/(.+)/) { run_jasmine_suite }

   # watch for changes to the assets directories and regenerate the assets when that happens
   watch(/assets\/(.+)/) do
      puts "regenerating assets"
      Rake::Task["compile:assets"].reenable
      Rake::Task["compile:assets"].invoke

      notify :head => "Assets Regenerated", :body => "an asset file changed", :icon => :success
   end

   # watch for changes in the uncompiled game datafiles and regenerate the game package when that happens
   watch(/game\/(.+)/) do
      puts "regenerating game package"

      Rake::Task["compile:world"].reenable
      Rake::Task["compile:world"].invoke

      notify :head => "Game Package Regenerated", :body => "a game file changed", :icon => :success
   end
end