require 'rubygems'
require 'mongoid'
require 'rake'
require 'database_cleaner'
require 'mongoid/version' # necessary for older versions of Mongoid (< ~3)

# Load rake tasks
load File.expand_path("../../lib/railties/denormalize.rake", __FILE__)
task :environment do
  Dir.chdir(File.dirname(__FILE__))
end

Mongoid.load!(File.expand_path('mongoid.yml', File.dirname(__FILE__)), :test)

require File.expand_path("../../lib/mongoid_denormalize", __FILE__)
Dir["#{File.dirname(__FILE__)}/app/models/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end