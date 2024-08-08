require 'cassandra'

class CassandraRecord
  def self.table_name
    self.name.tableize
  end

  def self.create(attributes)
    columns = attributes.keys.join(', ')
    placeholders = (['?'] * attributes.keys.size).join(', ')
    values = attributes.values.map { |v| format_value(v) }
    
    query = "INSERT INTO #{table_name} (#{columns}) VALUES (#{placeholders})"
    CASSANDRA_SESSION.execute(query, arguments: values)
    
    new(attributes)
  end

  def self.find(id)
    query = "SELECT * FROM #{table_name} WHERE id = ? LIMIT 1"
    result = CASSANDRA_SESSION.execute(query, arguments: [id]).first
    new(result) if result
  end

  def self.all
    query = "SELECT * FROM #{table_name}"
    results = CASSANDRA_SESSION.execute(query)
    results.map { |row| new(row) }
  end

  def initialize(attributes)
    attributes.each do |key, value|
      instance_variable_set("@#{key}", value)
      self.class.send(:attr_reader, key)
    end
  end

  private

  def self.format_value(value)
    case value
    when Cassandra::Uuid
      value
    when Time, DateTime
      value.to_i * 1000 #Arreglo por que el tiempo se buguea con cassandra
    when Date
      value.to_time.to_i * 1000 # lo misma challa
    else
      value
    end
  end
end