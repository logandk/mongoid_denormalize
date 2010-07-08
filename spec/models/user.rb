class User
  include Mongoid::Document
  include Mongoid::Denormalize
  
  field :name
  field :email
  
  references_many :posts
  references_many :comments
  
  denormalize :post_titles, :post_dates, :type => Array do |user, field|
    field == :post_titles ? user.posts.collect(&:title) : user.posts.collect(&:created_at).collect { |t| t + 300 }
  end
end