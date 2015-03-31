# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_denormalize/version'

Gem::Specification.new do |s|
  s.name = 'mongoid_denormalize'
  s.version = Mongoid::Denormalize::VERSION

  s.required_rubygems_version = ">= 1.3.6"
  s.authors                   = ['Logan Raarup']
  s.date                      = '2013-06-19'
  s.description               = %q{Helper module for denormalizing association attributes in Mongoid models.}
  s.summary                   = %q{Mongoid denormalization helper.}
  s.email                     = 'logan@logan.dk'
  s.extra_rdoc_files = [
    'LICENSE',
    'README.md'
  ]
  s.files = [
    'lib/mongoid_denormalize.rb',
    'lib/mongoid_denormalize/version.rb',
    'lib/railties/denormalize.rake',
    'lib/railties/railtie.rb'
  ]
  s.test_files       = ['spec/mongoid_denormalize_spec.rb']
  s.homepage         = 'http://github.com/logandk/mongoid_denormalize'
  s.require_paths    = ['lib']
  s.rubygems_version = '1.8.24'

  s.specification_version = 3

  s.add_dependency 'mongoid',     '~> 4.0.0'

end
