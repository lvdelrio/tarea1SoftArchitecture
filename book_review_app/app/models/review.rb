class Review < CassandraRecord
  def self.create(attributes)
    attributes[:id] ||= Cassandra::Uuid::Generator.new.now
    super(attributes)
  end

  #Filtro por libro
  def self.by_books(book_ids)
    query = "SELECT * FROM reviews WHERE book_id IN ? ALLOW FILTERING"
    results = CASSANDRA_SESSION.execute(query, arguments: [book_ids])
    results.map { |row| new(row) }
  end

  def self.average_score_for_book(book_id)
    query = "SELECT AVG(score) as avg_score FROM reviews WHERE book_id = ? ALLOW FILTERING"
    result = CASSANDRA_SESSION.execute(query, arguments: [Cassandra::Uuid.new(book_id)]).first
    result['avg_score'] || 0
  end

  def self.cached_average_score_for_book(book_id)
    Rails.cache.fetch("avg_score_book_#{book_id}", expires_in: 30.minutes) do
      average_score_for_book(book_id)
    end
  end
  
  #Cache
  def self.cached_find(uuid_string)
    Rails.cache.fetch("review_#{uuid_string}", expires_in: 1.hour) do
      Rails.logger.info "Cache miss for Review UUID: #{uuid_string}. Querying database."
      query = "SELECT * FROM reviews WHERE id = ? LIMIT 1"
      result = CASSANDRA_SESSION.execute(query, arguments: [Cassandra::Uuid.new(uuid_string)])
      row = result.first
      row ? new(row) : nil
    end
  end

  def self.clear_cache(uuid_string)
    Rails.cache.delete("review_#{uuid_string}")
  end
end