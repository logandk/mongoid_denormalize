require File.dirname(__FILE__) + '/railties/railtie' if defined?(Rails::Railtie)

# = Mongoid::Denormalize
#
# Helper module for denormalizing association attributes in Mongoid models.
module Mongoid::Denormalize
  extend ActiveSupport::Concern
  
  included do
    cattr_accessor :denormalize_definitions
    
    before_save :denormalize_from
    after_save :denormalize_to
    before_destroy :nullify_denormalize_to
  end

  module ClassMethods
    # Set a field or a number of fields to denormalize. Specify the associated object using the :from or :to options.
    #
    #   def Post
    #     include Mongoid::Document
    #     include Mongoid::Denormalize
    #
    #     referenced_in :user
    #     references_many :comments
    #
    #     denormalize :name, :avatar, :from => :user
    #     denormalize :created_at, :to => :comments
    #   end
    def denormalize(*fields)
      options = fields.pop
      
      (self.denormalize_definitions ||= []) << { :fields => fields, :options => options }

      # Define schema
      unless options[:to]
        fields.each { |name| field "#{options[:from]}_#{name}", :type => options[:type] || String }
      end
    end
    
    def is_denormalized?
      true
    end
  end

  def denormalized_valid?
    denormalize_from
    !self.changed?
  end

  def repair_denormalized!
    self.save! unless denormalized_valid?
  end
  
  private
    def denormalize_from
      self.denormalize_definitions.each do |definition|
        next if definition[:options][:to]
        
        definition[:fields].each { |name| self.send("#{definition[:options][:from]}_#{name}=", self.send(definition[:options][:from]).try(name)) }
      end
    end
    
    def denormalize_to
      self.denormalize_definitions.each do |definition|
        next unless definition[:options][:to]
        assigns = Hash[*definition[:fields].collect { |name| ["#{self.class.name.underscore}_#{name}", self.send(name)] }.flatten(1)]
        
      
        [definition[:options][:to]].flatten.each do |association|
          push_denormalized_values(association, assigns)
        end
      end
    end

    def nullify_denormalize_to
      self.denormalize_definitions.each do |definition|
        next unless definition[:options][:to]
        assigns = Hash[*definition[:fields].collect { |name| ["#{self.class.name.underscore}_#{name}", nil] }.flatten(1)]

        [definition[:options][:to]].flatten.each do |association|
          push_denormalized_values(association, assigns)
        end
      end
    end

    def push_denormalized_values(association, assigns)
      relation = []
      reflect = self.class.reflect_on_association(association)
      relation = reflect.relation.macro unless reflect.nil? || reflect.relation.nil?

      reflect.klass.skip_callback(:save, :before, :denormalize_from) if reflect.klass.try(:is_denormalized?)

      if [:embedded_in, :embeds_one, :referenced_in, :references_one, :has_one, :belongs_to].include? relation
        c = self.send(association)

        unless c.blank?
          assigns.each { |assign| c.send("#{assign[0]}=", assign[1]) }

          c.save
        end
      else
        c = self.send(association)

        c.to_a.each do |a|
          assigns.each { |assign| a.send("#{assign[0]}=", assign[1]) }

          a.save
        end
      end

      reflect.klass.set_callback(:save, :before, :denormalize_from) if reflect.klass.try(:is_denormalized?)
    end
end
