require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # how can self.table_name be parameterized? is this a risk?
    return @db_cols if @db_cols

    @db_cols ||= DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{self.table_name}
      LIMIT 0
    SQL

    @db_cols.flatten!.map!(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column_name|
      define_method("#{column_name}") { attributes[column_name] }

      define_method("#{column_name}=") do |val|
        attributes[column_name] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || "#{self}".tableize # still messes up 'human' though
  end

  def self.all
    raw_db_results = DBConnection.execute(<<-SQL)
      SELECT #{self.table_name}.*
      FROM #{self.table_name}
    SQL

    self.parse_all(raw_db_results)
  end

  def self.parse_all(results)
    # map, not each - we want the new array here
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{self.table_name}
      WHERE id = ?
      LIMIT 1
    SQL

    # ::parse_all will return either empty array, or 1-size array with this id
    # [].first => nil, anything_else.first => the found object
    self.parse_all(results).first
  end

  def initialize(params = {})
    params.each do |attr_name, attr_val|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end

      self.send("#{attr_name}=", attr_val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
