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


Options
-------

Denormalization can happen using an associated object as illustrated above, or using a block. The field type for denormalized fields must
be explicitly set if it is not a `String` value. Examples:

    # Basic denormalization. Will set the user_name attribute with the user name.
    denormalize :name, :from => :user
    
    # Override denormalized field name. Will set the from_email attribute with the user email.
    denormalize :email, :from => :user, :to => :from_email
    
    # Specify denormalized field type. Will set the post_created_at attribute as a Time object.
    denormalize :created_at, :type => Time, :from => :post
    
    # Multiple denormalization fields. Will set the user_name and user_email attributes with values from user.
    denormalize :name, :email, :from => :user
    
    # Block denormalization. Will set the comment_count attribute with the blocks return value.
    # The block receives the current instance as the first argument.
    denormalize(:comment_count, :type => Integer) { |post| post.comments.count }
    
    # Block denormalization with multiple fields. Will set the post_titles and post_dates attributes with the blocks return value.
    # The block receives the current instance as the first argument and the name of the denormalized field as the second argument.
    denormalize :post_titles, :post_dates, :type => Array do |user, field|
      field == :post_titles ? user.posts.collect(&:title) : user.posts.collect(&:created_at)
    end


Credits
-------

Copyright (c) 2010 Logan Raarup, released under the MIT license.