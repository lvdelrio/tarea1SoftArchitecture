class Author < CassandraRecord
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

  #Cache
  def self.cached_find(uuid_string)
    Rails.cache.fetch("author_#{uuid_string}", expires_in: 1.hour) do
      Rails.logger.info "Cache miss for Author UUID: #{uuid_string}. Querying database."
      query = "SELECT * FROM authors WHERE id = ? LIMIT 1"
      result = CASSANDRA_SESSION.execute(query, arguments: [Cassandra::Uuid.new(uuid_string)])
      row = result.first
      row ? new(row) : nil
    end
  end

  def self.clear_cache(uuid_string)
    Rails.cache.delete("author_#{uuid_string}")
  end

  def self.cached_find_by_name(name)
    Rails.cache.fetch("author_name_#{name}", expires_in: 1.hour) do
      find_by_name(name)
    end
  end
end