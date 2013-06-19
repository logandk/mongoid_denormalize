class User
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :name
  field :email
  field :nickname
  field :location, :type => Array

  has_one :post
  has_many :comments, :inverse_of => :user
  has_many :moderated_comments, :class_name => "Comment", :inverse_of => :moderator
  has_many :articles, :inverse_of => :author

  denormalize :name, :email, :location, :to => [:post, :comments]
  denormalize :nickname, :to => :moderated_comments, :as => :mod
  denormalize :name, :email, :to => :articles
end
