require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require 'jeweler'

spec_files = Rake::FileList["spec/**/*_spec.rb"]

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = spec_files
  t.spec_opts = ["-c"]
end

task :default => :spec

Jeweler::Tasks.new do |gemspec|
  gemspec.name = "mongoid_denormalize"
  gemspec.summary = "Mongoid denormalization helper."
  gemspec.description = "Helper module for denormalizing association attributes in Mongoid models."
  gemspec.add_runtime_dependency("mongoid", ["~>2.0.0.beta9"])
  gemspec.files = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  gemspec.require_path = 'lib'
  gemspec.email = "logan@logan.dk"
  gemspec.homepage = "http://github.com/logandk/mongoid_denormalize"
  gemspec.authors = ["Logan Raarup"]
end
Jeweler::GemcutterTasks.new