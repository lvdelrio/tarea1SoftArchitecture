class Book < CassandraRecord
  def self.create(attributes)
    attributes[:id] ||= Cassandra::Uuid::Generator.new.now
    attributes[:date_of_publication] = attributes[:date_of_publication].to_time if attributes[:date_of_publication].is_a?(Date)
    attributes[:author_id] ||= attributes[:author_id]
    super(attributes)
    new_book = super(attributes)

    new_book.update_elasticsearch if new_book

    new_book
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

  def self.search(query)
    if ElasticsearchService.enabled?
      elasticsearch_results = ElasticsearchService.search('books', query)
      elasticsearch_results.map { |result| new(result) }
    else
      fallback_search(query)
    end
  end

  def self.fallback_search(query)
    begin
      query_string = "SELECT * FROM books WHERE name LIKE ? OR summary LIKE ? ALLOW FILTERING"
      results = CASSANDRA_SESSION.execute(query_string, arguments: ["%#{query}%", "%#{query}%"])
      results.map { |row| new(row) }
    rescue Cassandra::Errors::InvalidError => e
      Rails.logger.error "Cassandra search error: #{e.message}"
      []
    end
  end

  private

  def update_elasticsearch
    document = {
      id: id,
      name: name,
      summary: summary,
      author_id: author_id,
      date_of_publication: date_of_publication
    }
    ElasticsearchService.index_document('books', id, document)
  end

  def delete_from_elasticsearch
    ElasticsearchService.delete_document('books', id)
  end

  def self.destroy(id)
    # Find and delete the book
    book = find(id)
    return unless book

    # Manually call after_destroy equivalent
    book.delete_from_elasticsearch
    super(id)
  end

  
end