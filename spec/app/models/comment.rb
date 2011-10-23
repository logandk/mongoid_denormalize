class Comment
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :body
  
  embedded_in :post, :inverse_of => :comments

  denormalize :created_at, :type => Time, :from => :post
end