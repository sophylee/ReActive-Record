require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    self.class_name.to_s.constantize
  end

  def table_name
    model_class.table_name ||
        self.class_name.downcase.pluralize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @primary_key = options[:primary_key] ||
        :id
    @foreign_key = options[:foreign_key] ||
        name.to_s.camelcase.concat("_id").downcase.to_sym
    @class_name = options[:class_name] ||
        name.to_s.capitalize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @primary_key = options[:primary_key] ||
        :id
    @foreign_key = options[:foreign_key] ||
        self_class_name.to_s.camelcase.concat("_id").downcase.to_sym
    @class_name = options[:class_name] ||
        name.to_s.capitalize.singularize
  end
end

module Associatable
  # Phase IVb

  def assoc_options
    @options ||= Hash.new
    @options
  end

  def belongs_to(name, options = {})
    name_sym = name.to_sym
    assoc_options[name_sym] = BelongsToOptions.new(name, options)
    options = assoc_options[name_sym]
    define_method("#{name}") do
      options.model_class.find(self.send(options.foreign_key))
    end
  end

  def has_many(name, options = {})
    name_sym = name.to_sym
    assoc_options[name_sym] = HasManyOptions.new(name, self, options)
    options = assoc_options[name_sym]
    define_method("#{name}") do
      options.class_name.to_s.constantize.where(options.foreign_key => self.id)
    end
  end

end

class SQLObject
  extend Associatable
end
