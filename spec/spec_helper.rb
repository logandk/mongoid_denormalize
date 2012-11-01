require 'rubygems'
#require 'spec'
require 'mongoid'
require 'yaml'
require 'rake'

# Load rake tasks
load File.expand_path("../../lib/railties/denormalize.rake", __FILE__)
task :environment do
  Dir.chdir(File.dirname(__FILE__))
end

Mongoid.configure do |config|
  config.connect_to("mongoid_denormalize_development")
end

require File.expand_path("../../lib/mongoid_denormalize", __FILE__)
Dir["#{File.dirname(__FILE__)}/app/models/*.rb"].each { |f| require f }
