require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'jeweler'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Jeweler::Tasks.new do |gemspec|
  gemspec.name = "mongoid_denormalize"
  gemspec.summary = "Mongoid denormalization helper."
  gemspec.description = "Helper module for denormalizing association attributes in Mongoid models."
  gemspec.files = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  gemspec.require_path = 'lib'
  gemspec.email = "logan@logan.dk"
  gemspec.homepage = "http://github.com/logandk/mongoid_denormalize"
  gemspec.authors = ["Logan Raarup"]
end
Jeweler::GemcutterTasks.new