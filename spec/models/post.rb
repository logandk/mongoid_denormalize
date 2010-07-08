class Post
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :title
  field :body
  field :created_at, :type => Time
  
  referenced_in :user
  references_many :comments
  
  denormalize :name, :email, :from => :user
  denormalize(:comment_count, :type => Integer) { |post| post.comments.count }
end