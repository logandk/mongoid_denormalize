Mongoid::Denormalize
====================

*Note: I am no longer actively maintaining this module, and I do not know whether it is compatible with newer versions of mongoid. If you would like to take ownership of this repository, please let me know.*


Helper module for denormalizing association attributes in Mongoid models. Why denormalize? Read *[A Note on Denormalization](http://www.mongodb.org/display/DOCS/MongoDB+Data+Modeling+and+Rails#MongoDBDataModelingandRails-ANoteonDenormalization)*.

Extracted from [coookin'](http://coookin.com), where it is used in production.


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
    denormalize :name, :email, :from => :user



Example
-------

    class User
      include Mongoid::Document
      include Mongoid::Denormalize

      has_many :comments

      field :name
      field :email
      
      denormalize :name, :email, :to => :comments
    end
    
    class Comment
      include Mongoid::Document
      include Mongoid::Denormalize

      belongs_to :user

      field :body
      
      denormalize :name, :email, :from => :user
    end
    
    >> user = User.create(:name => "John Doe", :email => "john@doe.com")
    >> comment = Comment.create(:body => "Lorem ipsum...", :user => user)
    >> user.comments << comment
    >> comment.user_name
    "John Doe"
    >> comment.user_email
    "john@doe.com"
    >> user.update_attributes(:name => "Bill")
    >> comment.user_name
    "Bill"


Options
-------

Denormalization can happen in either or both directions. When using the `:from` option, the associated objects will fetch the values from
the parent. When using the `:to` option, the parent will push the values to its children.

    # Basic denormalization. Will set the user_name attribute with the associated user's name.
    denormalize :name, :from => :user
    
    # Basic denormalization. Will set the user_name attribute of "self.comments" to the value of "self.name".
    denormalize :name, :to => :comments
    
    # Multiple fields. Will set the user_name and user_email attributes with the associated user's name and email.
    denormalize :name, :email, :from => :user
    
    # Multiple children. Will set the user_name attribute of "self.posts" and "self.comments" with "self.name".
    denormalize :name, :to => [:posts, :comments]

    # With custom field name prefix. Will set the commenter_name attribute of "self.comments".
    denormalize :name, :to => :comments, :as => :commenter

You must specify the type of all denormalizations when using the `:from` option, unless the denormalized type is `String`, the default.
 
    # in User
    field :location, :type => Array
    denormalize :location, :to => :posts
    
    # in Post
    denormalize :location, :type => Array, :from => :user

Rake tasks
----------

A rake task is included for verifying and repairing inconsistent denormalizations. This might be useful your records may be modified
without Mongoid, or if you are using relational associations in combination with embedded records (see *Known issues*).

    rake db:denormalize
    
This task will only update records that have outdated denormalized fields.


Known issues
------------

**Relational associations in combination with embedded records**

It is not recommended nor supported to use mongoid_denormalize to perform denormalization to embedded records through a relational association because
 MongoDB/Mongoid do not support direct access to embedded fields via a relational association.

So, if User has_many :posts and User has_many :comments, but Comments are embedded_in :post, a user can't directly access a comment.

Contributing
-------

Clone the repository and install jeweler with `gem install jeweler` so that you can run the rake tasks.

Contributors
-------
* hubsmoke (https://github.com/hubsmoke)
* Leo Lou (https://github.com/l4u)
* Austin Bales (https://github.com/arbales)
* Isaac Cambron (https://github.com/icambron)
* Shannon Carey (https://github.com/rehevkor5)


Credits
-------

Copyright (c) 2010 Logan Raarup, released under the MIT license.
