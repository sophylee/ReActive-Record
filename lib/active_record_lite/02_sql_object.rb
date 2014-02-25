require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    all = []
    results.each do |result|
      p result
      p '************'
      all << self.new(result)
    end
    all
  end
end

class SQLObject < MassObject
  def self.columns
    columns = DBConnection.execute2("SELECT * FROM #{self.table_name}").first
    columns.each do |col_name|
      define_method("#{col_name.to_sym}=") { |val| attributes[col_name] = val }
      define_method("#{col_name.to_sym}") { return attributes[col_name] }
    end
    return columns
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
    results = []
    object_arr = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    object_arr.each do |object_hash|
      results << object_hash
    end
    self.parse_all(results)
  end

  def self.find(id)
    # ...
  end

  def attributes
    @attributes ||= Hash.new
  end

  def insert
    # ...
  end

  def initialize(params)
    attributes
    columns = self.class.columns
    params.each do |attr_name, value|
      p "-------------------"
      p attr_name
      p columns
      p '====================='
      if columns.include?(attr_name)
        @attributes[attr_name.to_sym] = value
      else
        raise "unknown attribute #{attr_name}"
      end
    end
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
