# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_denormalize/version'

Gem::Specification.new do |s|
  s.name = 'mongoid_denormalize'
  s.version = Mongoid::Denormalize::VERSION

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Logan Raarup']
  s.description = %q{Helper module for denormalizing association attributes in Mongoid models.}
  s.summary = %q{Mongoid denormalization helper.}
  s.email = 'logan@logan.dk'
  s.license = 'MIT'
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
  s.test_files = ['spec/mongoid_denormalize_spec.rb']
  s.homepage = 'http://github.com/logandk/mongoid_denormalize'
  s.require_paths = ['lib']
  s.rubygems_version = '1.8.24'

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ['>= 0'])
      s.add_development_dependency(%q<guard-rspec>, ['>= 0'])
      s.add_runtime_dependency(%q<mongoid>, ['>= 4.0.0'])
    else
      s.add_dependency(%q<rake>, ['>= 0'])
      s.add_dependency(%q<guard-rspec>, ['>= 0'])
      s.add_dependency(%q<mongoid>, ['>= 4.0.0'])
    end
  else
    s.add_dependency(%q<rake>, ['>= 0'])
    s.add_dependency(%q<guard-rspec>, ['>= 0'])
    s.add_dependency(%q<mongoid>, ['>= 4.0.0'])
  end
end
