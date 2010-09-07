class User
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :name
  field :email
  
  references_one :post
  references_many :comments
  
  denormalize :name, :email, :to => [:post, :comments]
end