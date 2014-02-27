require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]
    source_options = through_options.model_class.assoc_options[source_name]
    through_foreign_key = through_options.foreign_key
    source_foreign_key = source_options.foreign_key

    select_line = "#{source_options.table_name}.*"
    from_line = source_options.table_name
    join_line = <<-SQL
      #{source_options.table_name} ON
      #{through_options.table_name}.#{source_foreign_key} =
      #{source_options.table_name}.id
    SQL
    where_line = "#{through_options.primary_key} = ?"
    define_method("#{name}") do
      results = DBConnection.execute(<<-SQL, self.id)
      SELECT
        #{select_line}
      FROM
        #{from_line}
      WHERE
        #{where_line}
      SQL
      source_options.model_class.parse_all(results).first
    end
  end
end
