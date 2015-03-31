require 'rubygems'
require 'bundler'
require 'rake'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)

task :console do
  require 'irb'
  require 'irb/completion'
  require 'mongoid'
  require 'mongoid_denormalize'
  require_relative 'spec/app/models/article'
  require_relative 'spec/app/models/comment'
  require_relative 'spec/app/models/post'
  require_relative 'spec/app/models/user'
  ARGV.clear
  IRB.start
end

task :default => :spec
