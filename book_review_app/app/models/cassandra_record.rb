class CassandraRecord
  def self.table_name
    self.name.tableize
  end

  def self.create(attributes)
    columns = attributes.keys.join(', ')
    values = attributes.values.map { |v| "'#{v}'" }.join(', ')
    CASSANDRA_SESSION.execute("INSERT INTO #{table_name} (#{columns}) VALUES (#{values})")
  end

  def self.find(id)
    result = CASSANDRA_SESSION.execute("SELECT * FROM #{table_name} WHERE id = #{id} LIMIT 1").first
    new(result) if result
  end

  def initialize(attributes)
    attributes.each do |key, value|
      instance_variable_set("@#{key}", value)
      self.class.send(:attr_reader, key)
    end
  end
end