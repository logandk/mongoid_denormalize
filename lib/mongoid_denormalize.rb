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
    def denormalize(*args)
      *fields, options = args
      
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
    Array(self.denormalize_definitions).reject do |definition|
      definition[:options][:to]
    end.each do |definition|
      definition[:fields].each do |name|
        field = definition[:options][:from]
        # force reload if :from method is an association ; call it normally otherwise
        associated =  self.class.reflect_on_association(field) ? self.send(field, true) : self.send(field)
        self.send("#{field}_#{name}=", associated.try(name))
      end
    end
  end

  def denormalize_to
    Array(self.denormalize_definitions).find_all do |definition|
      definition[:options][:to]
    end.each do |definition|
      as = definition[:options][:as]

      assignments = definition[:fields].collect do |source_field|
        {
          :source_field => source_field.to_s,
          :value => self.send(source_field)
        }
      end

      Array(definition[:options][:to]).each do |association|
        relation = []
        reflect = self.class.reflect_on_association(association)
        relation = reflect.relation.macro unless reflect.nil? || reflect.relation.nil?

        reflect.klass.skip_callback(:save, :before, :denormalize_from) if reflect.klass.try(:is_denormalized?)

        associated = self.send(association)
        prefix = (as || reflect.inverse_of || reflect.inverse_class_name).to_s.underscore
        
        if [:embedded_in, :embeds_one, :referenced_in, :references_one, :has_one, :belongs_to].include? relation
          unless associated.blank?
            assign_and_save(associated, assignments, prefix)
          end
        else
          associated.to_a.each { |c| assign_and_save(c, assignments, prefix) }
        end
        
        reflect.klass.set_callback(:save, :before, :denormalize_from) if reflect.klass.try(:is_denormalized?)
      end
    end
  end

  def assign_and_save(obj, assignments, prefix)
    attributes_hash = Hash[assignments.collect do |assignment|
      if self.changed_attributes.has_key?(assignment[:source_field])
        ["#{prefix}_#{assignment[:source_field]}", assignment[:value]]
      end
    end]
    
    unless attributes_hash.empty?
      # The more succinct update_attributes(changes, :without_protection => true) requires Mongoid 3.0.0, 
      # but we only require 2.1.9
      obj.assign_attributes(attributes_hash, :without_protection => true)
      obj.save(:validate => false)
    end
  end
end
