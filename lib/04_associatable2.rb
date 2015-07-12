require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    p "RUNNING has_one_through with..."
    p "name: #{name} | through_name: #{through_name} | source_name: #{source_name}"
    p "ALL assoc options are: #{assoc_options.inspect}"

    # through_opts is actually the assoc_options for the class of `self`
    # ::assoc_options returns a hash with the key of class `self`

    define_method(name) do
      through_opts = self.class.assoc_options[through_name]
      source_opts = through_opts.model_class.assoc_options[source_name]

      puts "== INSIDE method definition `#{name}` =="
      puts "through_opts: #{through_opts.inspect}"
      puts "source_opts: #{source_opts.inspect}"

      through_table = through_opts.table_name
      join_table = source_opts.class_name.tableize

      selectline = "SELECT #{through_table}.*"
      fromline = "FROM #{through_table}"
      joinline = "JOIN #{join_table}"
      online = "ON #{through_table}.#{source_opts.foreign_key} = #{join_table}.#{source_opts.primary_key}"
      whereline = "WHERE #{through_table}.#{through_opts.primary_key} = #{self.send(through_opts.foreign_key)}"

      p selectline
      p fromline
      p joinline
      p online
      p whereline
      p "self: #{self} | #{self.inspect}"

      binds = { select: selectline, from: fromline, where: whereline,
                join: joinline, on: online }


      results = DBConnection.execute(<<-SQL, *binds)

      SQL

      p results
    end

  end
end
