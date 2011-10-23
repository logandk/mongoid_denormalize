class Post
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :title
  field :body
  field :created_at, :type => Time
  
  belongs_to :user
  has_many :comments
  
  denormalize :location, :type => Array, :from => :user
  denormalize :name, :email, :from => :user
  denormalize :created_at, :to => :comments
end