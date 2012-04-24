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
      assigns = Hash[*definition[:fields].collect { |name| [name, self.send(name)] }.flatten(1)]


      [definition[:options][:to]].flatten.each do |association|
        relation = []
        reflect = self.class.reflect_on_association(association)
        relation = reflect.relation.macro unless reflect.nil? || reflect.relation.nil?

        reflect.klass.skip_callback(:save, :before, :denormalize_from) if reflect.klass.try(:is_denormalized?)

        association_s = association.to_s
        associated = self.send(association)
        prefix = (reflect.inverse_of || reflect.inverse_class_name).to_s.underscore

        chgs = assigns.inject({}){ |m,(k,v)| m["#{prefix}_#{k}"]= v; m }

        if association_s == association_s.pluralize
          associated.criteria.update_all chgs
          associated.each{ |document| document.write_attributes chgs, false }
        elsif associated
          associated.update_attributes chgs
        end

        reflect.klass.set_callback(:save, :before, :denormalize_from) if reflect.klass.try(:is_denormalized?)
      end
    end
  end
end
