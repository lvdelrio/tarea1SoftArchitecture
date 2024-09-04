require 'cassandra'

class CassandraRecord
  include ActiveModel::Model
  include ActiveModel::Attributes
  attr_accessor :id
  def self.table_name
    self.name.tableize
  end
  def to_model
    self
  end

  def to_key
    [id] if persisted?
  end

  def persisted?
    !id.nil?
  end

  def model_name
    @_model_name ||= ActiveModel::Name.new(self.class)
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

  def self.create(attributes)
    attributes[:id] ||= Cassandra::Uuid::Generator.new.now
    columns = attributes.keys.join(', ')
    placeholders = (['?'] * attributes.keys.size).join(', ')
    values = attributes.values.map { |v| format_value(v) }
    
    query = "INSERT INTO #{table_name} (#{columns}) VALUES (#{placeholders})"
    CASSANDRA_SESSION.execute(query, arguments: values)
    
    new(attributes)
  end

  def initialize(attributes = {})
    attributes.each do |key, value|
      instance_variable_set("@#{key}", value)
      self.class.send(:attr_accessor, key) unless self.class.method_defined?(key)
    end
  end

  def save
    if @id.nil?
      # This is a new record, so we need to create it
      attributes = self.instance_variables.each_with_object({}) do |var, hash|
        key = var.to_s.delete('@')
        hash[key] = instance_variable_get(var)
      end
      attributes[:id] = Cassandra::Uuid::Generator.new.now
      self.class.create(attributes)
      true
    else
      # This is an existing record, so we need to update it
      attributes = self.instance_variables.each_with_object({}) do |var, hash|
        key = var.to_s.delete('@')
        value = instance_variable_get(var)
        hash[key] = value unless value.nil? || key == 'id'
      end
      update_query = "UPDATE #{self.class.table_name} SET #{attributes.keys.map { |k| "#{k} = ?" }.join(', ')} WHERE id = ?"
      values = attributes.values + [@id]
      CASSANDRA_SESSION.execute(update_query, arguments: values)
      true
    end
  rescue Cassandra::Errors::InvalidError => e
    Rails.logger.error "Failed to save record: #{e.message}"
    false
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