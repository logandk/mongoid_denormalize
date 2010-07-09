# = Mongoid::Denormalize
#
# Helper module for denormalizing association attributes in Mongoid models.
module Mongoid::Denormalize
  extend ActiveSupport::Concern

  included do
    cattr_accessor :denormalize_definitions
  end

  module ClassMethods
    # Set a field or a number of fields to denormalize. Specify the associated object using the :from option.
    #
    #   def Post
    #     include Mongoid::Document
    #     include Mongoid::Denormalize
    #
    #     referenced_in :user
    #     references_many :comments
    #
    #     denormalize :name, :avatar, :from => :user
    #
    #     denormalize :email, :from => :user, :to => :from_email
    #
    #     denormalize :comment_count, :type => Integer do |post|
    #       post.comments.count
    #     end
    #   end
    def denormalize(*fields, &block)
      options = fields.pop
      
      (self.denormalize_definitions ||= []) << { :fields => fields, :options => options, :block => block}

      # Define schema
      fields.each do |name|
        denormalized_name = if block_given?
          name
        else
          options[:to] ? options[:to] : "#{options[:from]}_#{name}"
        end
        
        field denormalized_name, :type => options[:type]
      end
      
      before_validation :denormalize_fields
    end
  end

  private
    def denormalize_fields
      self.denormalize_definitions.each do |definition|
        definition[:fields].each do |name|
          if definition[:block]
            value = (definition[:fields].length > 1 ? definition[:block].call(self, name) : definition[:block].call(self))
            self.send("#{name}=", value)
          else
            attribute_name = (definition[:options][:to] ? definition[:options][:to] : "#{definition[:options][:from]}_#{name}")
            self.send("#{attribute_name}=", self.send(definition[:options][:from]).try(name))
          end
        end
      end
    end
end