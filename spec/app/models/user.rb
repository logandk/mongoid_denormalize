class User
  include Mongoid::Document
  include Mongoid::Denormalize

  field :name
  field :email
  field :location, :type => Array

  has_one :post
  has_many :comments
  has_many :articles, :inverse_of => :author

  denormalize :name, :email, :location, :to => [:post, :comments]
  denormalize :name, :email, :to => :articles
end
