require 'rails'

module Mongoid::Denormalize
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'railties/denormalize.rake'
    end
  end
end