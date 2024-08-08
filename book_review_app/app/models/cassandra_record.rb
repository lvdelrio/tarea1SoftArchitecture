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