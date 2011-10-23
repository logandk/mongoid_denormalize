class User
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :name
  field :email
  field :location, :type => Array
  
  has_one :post
  
  def comments=(val)
    post ||= Post.new
    post.comments = val
  end
  
  def comments
    post ||= Post.new
    post.comments
  end
  
  denormalize :name, :email, :to => [:post, :comments]
  denormalize :location, :to => :post
end