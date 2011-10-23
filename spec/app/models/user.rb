class User
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :name
  field :email
  field :location, :type => Array
  
  has_one :post
  has_many :comments
  
  denormalize :name, :email, :location, :to => [:post, :comments]
end