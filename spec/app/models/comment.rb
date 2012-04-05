class Comment
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :body
  
  belongs_to :post, :inverse_of => :comments
  belongs_to :user
  belongs_to :moderator, :class_name => "User", :inverse_of => :moderated_comments

  attr_accessible :body, :user, :moderator
  
  denormalize :location, :type => Array, :from => :user
  denormalize :name, :from => :user
  denormalize :email, :from => :user
  denormalize :created_at, :type => Time, :from => :post
  denormalize :nickname, :from => :moderator
end