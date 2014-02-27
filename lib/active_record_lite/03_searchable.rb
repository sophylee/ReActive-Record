require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    table = self.table_name
    where_line = params.keys.map { |key| "#{key} = ?" }.join(" AND ")
    results = DBConnection.execute(<<-SQL, params.values)
    SELECT
      *
    FROM
      #{table}
    WHERE
      #{where_line}
    SQL
    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
