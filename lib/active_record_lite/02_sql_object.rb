require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    # ...
  end
end

class SQLObject < MassObject
  def self.columns
    # ...
  end

  def self.table_name=(table_name)
    unless table_name.nil?
      @table_name = table_name
    end
  end

  def self.table_name
    if !!@table_name
      return @table_name
    else
      @table_name = self.to_s.underscore.pluralize
    end
  end

  def self.all
    # self.find_by_sql([<<-SQL, self.table_name])
    # SELECT
    #   *
    # FROM
    #   ?
    # SQL
  end

  def self.find(id)
    # ...
  end

  def attributes
    # @attributes ||=
  end

  def insert
    # ...
  end

  def initialize
    # ...
  end

  def save
    # ...
  end

  def update
    # ...
  end

  def attribute_values
    # ...
  end
end
