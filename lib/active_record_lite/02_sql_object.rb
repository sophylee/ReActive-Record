require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    all = []
    results.each do |result|
      all << self.new(result)
    end
    all
  end
end

class SQLObject < MassObject
  def self.columns
    query = "SELECT * FROM #{self.table_name}"
    columns = DBConnection.execute2(query).first.map(&:to_sym)

    columns.each do |column|
      define_method("#{column}=") { |val| attributes[column] = val }
      define_method("#{column}") { attributes[column] }
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
      #{self.table_name};
    SQL
    object_arr.each do |object_hash|
      results << object_hash
    end
    self.parse_all(results)
  end

  def self.find(id)
    object = DBConnection.execute(<<-SQL, id)
        SELECT
          *
        FROM
          #{self.table_name}
        WHERE
          id = ?;
          SQL
    # object.first returns params for an object.
    # The line below builds an object using those params.
    new_obj = self.new(object.first)
  end

  def attributes
    @attributes ||= Hash.new
  end

  def insert
    table = self.class.table_name
    value_count = self.attributes.keys.count
    col_names = self.attributes.keys.join(", ")
    values = self.attribute_values
    question_marks = (["?"] * value_count).join(", ")
    DBConnection.execute(<<-SQL, *values)
    INSERT INTO
      #{table} (#{col_names})
    VALUES
      (#{question_marks});
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(*params)
    attributes
    columns = self.class.columns
    unless params.empty?
      params.first.each do |attr_name, value|
        if columns.include?(attr_name.to_sym)
          @attributes[attr_name.to_sym] = value
        else
          raise "unknown attribute #{attr_name}"
        end
      end
    end
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end

  def update
    table = self.class.table_name
    values = attribute_values
    set_line = self.attributes.keys.map { |col| "#{col} = ?" }.join(", ")
    DBConnection.execute(<<-SQL, *values, self.id)
    UPDATE
      #{table}
    SET
      #{set_line}
    WHERE
      id = ?;
    SQL
  end

  def attribute_values
    values = []
    @attributes.each do |attr_name, value|
      values << value
    end
    values
  end
end
