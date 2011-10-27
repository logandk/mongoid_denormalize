class Comment
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :body
  
  belongs_to :post, :inverse_of => :comments
  belongs_to :user

  
  denormalize :location, :type => Array, :from => :user
  denormalize :name, :from => :user
  denormalize :email, :from => :user
  denormalize :created_at, :type => Time, :from => :post
end