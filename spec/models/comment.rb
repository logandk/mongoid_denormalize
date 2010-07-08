class Comment
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :body
  
  referenced_in :post
  referenced_in :user
  
  denormalize :name, :from => :user
  denormalize :email, :from => :user, :to => :from_email
  denormalize :created_at, :type => Time, :from => :post
end