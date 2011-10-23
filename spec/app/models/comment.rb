class Comment
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :body
  
  embedded_in :post, :inverse_of => :comments
  
  def user
    post ||= Post.new
    post.user
  end
  
  def user=(val)
    post ||= Post.new
    post.user = val
  end
  
  denormalize :location, :type => Array, :from => :user
  denormalize :name, :from => :user
  denormalize :email, :from => :user
  denormalize :created_at, :type => Time, :from => :post
end