class Author < CassandraRecord
  include Searchable
  
  def self.create(attributes)
    attributes[:id] ||= Cassandra::Uuid::Generator.new.now
    attributes[:date_of_birth] = attributes[:date_of_birth].to_time if attributes[:date_of_birth].is_a?(Date)
    super(attributes)
  end

  def self.find_by_name(name)
    Rails.logger.info "Attempting to find author with name: #{name.inspect}"

    if name.nil? || name.empty?
      Rails.logger.warn "Attempted to find author with null or empty name"
      return nil
    end

    begin
      query = "SELECT * FROM authors WHERE name = ? ALLOW FILTERING"
      result = CASSANDRA_SESSION.execute(query, arguments: [name]).first
      Rails.logger.info "Query result: #{result.inspect}"
      new(result) if result
    rescue Cassandra::Errors::InvalidError => e
      Rails.logger.error "Error finding author by name: #{e.message}"
      nil
    end
  end
end