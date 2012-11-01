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

      (self.denormalize_definitions ||= []) << {:fields => fields, :options => options}

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
    unless denormalize_definitions.nil?
      self.denormalize_definitions.each do |definition|
        next if definition[:options][:to]

        definition[:fields].each do |name|
          field = definition[:options][:from]
          # force reload if :from method is an association ; call it normally otherwise
          associated = self.class.reflect_on_association(field) ? self.send(field, true) : self.send(field)
          self.send("#{field}_#{name}=", associated.try(name))
        end
      end
    end
  end

  def denormalize_to
    unless denormalize_definitions.nil?
      self.denormalize_definitions.each do |definition|
        next unless definition[:options][:to]
        as = definition[:options][:as]
        prefix = as ? as : self.class.name.underscore

        assigns = Hash[*definition[:fields].collect { |name| ["#{prefix}_#{name}", self.send(name)] }.flatten(1)]

        [definition[:options][:to]].flatten.each do |association|
          push_denormalized_values(association, assigns)
        end
      end
    end
  end

  def nullify_denormalize_to
    unless denormalize_definitions.nil?
      self.denormalize_definitions.each do |definition|
        next unless definition[:options][:to]
        as = definition[:options][:as]
        prefix = as ? as : self.class.name.underscore

        assigns = Hash[*definition[:fields].collect { |name| ["#{prefix}_#{name}", nil] }.flatten(1)]

        [definition[:options][:to]].flatten.each do |association|
          push_denormalized_values(association, assigns)
        end
      end
    end
  end

  def push_denormalized_values(association, assigns)
    relation = []
    reflect = self.class.reflect_on_association(association)
    relation = reflect.relation.macro unless reflect.nil? || reflect.relation.nil?

    reflect.klass.skip_callback(:save, :before, :denormalize_from)

    if [:embedded_in, :embeds_one, :referenced_in, :references_one, :has_one, :belongs_to].include? relation
      c = self.send(association)

      unless c.blank?
        assigns.each { |assign| c.set(assign[0],assign[1]) }
      end
    else
      c = self.send(association)

      c.to_a.each do |a|
        a.repair_denormalized!
        assigns.each { |assign| a.set(assign[0],assign[1]) }

      end

    end

    reflect.klass.set_callback(:save, :before, :denormalize_from)
  end
end
