Mongoid::Denormalize
====================

Helper module for denormalizing association attributes in Mongoid models. Why denormalize? Read *[A Note on Denormalization](http://www.mongodb.org/display/DOCS/MongoDB+Data+Modeling+and+Rails#MongoDBDataModelingandRails-ANoteonDenormalization)*.


Installation
------------

Add the gem to your Bundler `Gemfile`:

    gem 'mongoid_denormalize'

Or install with RubyGems:

    $ gem install mongoid_denormalize


Usage
-----

In your model:

    # Include the helper method
    include Mongoid::Denormalize
    
    # Define your denormalized fields
    denormalize :title, :from => :post
    denormalize :name, :avatar, :from => :user



Example
-------

    def User
      include Mongoid::Document
      include Mongoid::Denormalize

      references_many :posts

      field :name
      field :avatar
    end
    
    def Post
      include Mongoid::Document
      include Mongoid::Denormalize

      referenced_in :user

      field :title
      denormalize :name, :avatar, :from => :user
    end
    
    >> user = User.create(:name => "John Doe", :avatar => "http://url/to/avatar.png")
    >> post = Post.create(:title => "Blog post", :user => user)
    >> post.user_name
    "John Doe"
    >> post.user_avatar
    "http://url/to/avatar.png"
    >> user.update_attributes(:name => "Bill")
    >> post.save
    >> post.user_name
    "Bill"


Credits
-------

Copyright (c) 2010 Logan Raarup, released under the MIT license.