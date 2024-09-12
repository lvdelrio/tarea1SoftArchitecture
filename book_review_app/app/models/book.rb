class Book < CassandraRecord
  def self.create(attributes)
    attributes[:id] ||= Cassandra::Uuid::Generator.new.now
    attributes[:date_of_publication] = attributes[:date_of_publication].to_time if attributes[:date_of_publication].is_a?(Date)
    attributes[:author_id] ||= attributes[:author_id]
    super(attributes)
  end

  #Filtro por autor
  def self.by_author(author_id)
    query = "SELECT * FROM books WHERE author_id = ? ALLOW FILTERING"
    results = CASSANDRA_SESSION.execute(query, arguments: [author_id])
    results.map { |row| new(row) }
  end

  def self.all
    query = "SELECT * FROM books"
    results = CASSANDRA_SESSION.execute(query)
    results.map { |row| new(row) }
  end
  def self.search(query)
    begin
      query_string = "SELECT * FROM books WHERE name = ? ALLOW FILTERING"
      results = CASSANDRA_SESSION.execute(query_string, arguments: [query])
      results.map { |row| new(row) }
    rescue Cassandra::Errors::InvalidError => e
      Rails.logger.error "Cassandra search error: #{e.message}"
      []
    end
  end

  def self.by_publication_date_range(start_date, end_date)
    query_string = "SELECT * FROM books WHERE date_of_publication >= ? AND date_of_publication <= ? ALLOW FILTERING"
    results = CASSANDRA_SESSION.execute(query_string, arguments: [start_date.to_time, end_date.to_time])
    results.map { |row| new(row) }
  end

  def self.create_with_author_name(attributes)
    author_name = attributes.delete(:author_name)
    author = Author.find_by_name(author_name)
    
    return nil unless author

    attributes[:author_id] = author.id
    create(attributes)
  end

  def self.create(attributes)
    attributes[:id] ||= Cassandra::Uuid::Generator.new.now
    attributes[:date_of_publication] = attributes[:date_of_publication].to_time if attributes[:date_of_publication].is_a?(String)
    super(attributes)
  end

  #Cache
  def self.cached_find(uuid_string)
    Rails.logger.info "Attempting to find book with UUID: #{uuid_string}"
    begin
      cached_book = Rails.cache.fetch("book_#{uuid_string}", expires_in: 1.hour) do
        Rails.logger.info "Cache miss for UUID: #{uuid_string}. Querying database."
        query = "SELECT * FROM books WHERE id = ? LIMIT 1"
        result = CASSANDRA_SESSION.execute(query, arguments: [Cassandra::Uuid.new(uuid_string)])
        row = result.first
        if row
          Rails.logger.info "Book found in database."
          new(row)
        else
          Rails.logger.info "Book not found in database."
          nil
        end
      end
  
      if cached_book
        Rails.logger.info "Book found in cache or database. Object ID: #{cached_book.object_id}"
      else
        Rails.logger.info "Book not found in cache or database."
      end
  
      cached_book
    rescue Redis::CannotConnectError => e
      Rails.logger.error "Redis connection error: #{e.message}"
      nil
    rescue => e
      Rails.logger.error "Unexpected error in cached_find: #{e.message}"
      nil
    end
  end

  def self.clear_cache(uuid_string)
    Rails.cache.delete("book_#{uuid_string}")
  end

  def cached_reviews_count
    Rails.cache.fetch("book_#{id}_reviews_count", expires_in: 30.minutes) do
      reviews.count
    end
  end
  
  def self.test_redis
    begin
      test_key = "test_key_#{Time.now.to_i}"
      test_value = "test_value"
      Rails.cache.write(test_key, test_value, expires_in: 1.minute)
      retrieved_value = Rails.cache.read(test_key)
      
      if retrieved_value == test_value
        Rails.logger.info "Redis test successful. Value stored and retrieved correctly."
        true
      else
        Rails.logger.error "Redis test failed. Retrieved value does not match stored value."
        false
      end
    rescue => e
      Rails.logger.error "Redis test failed with error: #{e.message}"
      false
    end
  end
end