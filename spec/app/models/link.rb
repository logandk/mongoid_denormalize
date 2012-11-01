class Link
  include Mongoid::Document
  include Mongoid::Denormalize # Mongoid::Denormalize is included but for test purposes denormalize is never called.

  field :name
  field :href

  belongs_to :post, :inverse_of => :links
end