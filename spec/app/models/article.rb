class Article
  include Mongoid::Document
  include Mongoid::Denormalize

  field :title
  field :body
  field :created_at, :type => Time

  belongs_to :author, :class_name => 'User'

  denormalize :name, :email, :from => :author
end
