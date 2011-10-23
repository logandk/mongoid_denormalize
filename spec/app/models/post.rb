class Post
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :title
  field :body
  field :created_at, :type => Time
  
  belongs_to :user
  embeds_many :comments
  
  denormalize :name, :email, :location, :from => :user
  denormalize :created_at, :to => :comments
end