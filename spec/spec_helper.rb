require 'rubygems'
require 'spec'
require 'mongoid'
require 'yaml'

Mongoid.configure do |config|
  settings = YAML.load(File.read(File.join(File.dirname(__FILE__), "database.yml")))
  
  db = Mongo::Connection.new(settings['host'], settings['port']).db(settings['database'])
  db.authenticate(settings['username'], settings['password'])
  
  config.master = db
end

require File.expand_path("../../lib/mongoid_denormalize", __FILE__)
Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |f| require f }