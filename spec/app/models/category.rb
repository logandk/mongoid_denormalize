class Category
  include Mongoid::Document
  include Mongoid::Denormalize

  field :name

  has_many :posts, :dependent => :nullify

  denormalize :name, :to => :posts
end
