class Post
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :title
  field :body
  field :created_at, :type => Time
  
  belongs_to :user
  belongs_to :category
  has_many :comments
  
  denormalize :location, :type => Array, :from => :user
  denormalize :name, :email, :from => :user
  denormalize :name, :from => :category
  denormalize :created_at, :to => :comments
end
