class User
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :name
  field :email
  field :nickname
  field :location, :type => Array

  has_one :post
  has_many :comments
  has_many :moderated_comments, :class_name => "Comment", :inverse_of => :moderator
  
  denormalize :name, :email, :location, :to => [:post, :comments]
  denormalize :nickname, :to => :moderated_comments, as: :moderator
end