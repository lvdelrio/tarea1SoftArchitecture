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

  def self.format_value(value)
    case value
    when Cassandra::Uuid
      value
    when Time, DateTime, Date
      value.strftime('%Y-%m-%d')
    else
      value
      end
    end

  def self.find(id)
    result = CASSANDRA_SESSION.execute("SELECT * FROM #{table_name} WHERE id = ? LIMIT 1", arguments: [id]).first
    new(result) if result
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
      value.strftime('%Y-%m-%d %H:%M:%S')
    else
      value
    end
  end
end