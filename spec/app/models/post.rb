class Post
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :title
  field :body
  field :created_at, :type => Time
  
  referenced_in :user
  embeds_many :comments
  
  denormalize :name, :email, :from => :user
  denormalize :created_at, :to => :comments
end