class User
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :name
  field :email
  
  has_one :post
  
  denormalize :name, :email, :to => :post
end