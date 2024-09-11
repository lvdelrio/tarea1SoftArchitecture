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
    result = CASSANDRA_SESSION.execute(query, arguments: [book_id]).first
    result['avg_score'] || 0
  end

  after_save :update_elasticsearch
  after_destroy :delete_from_elasticsearch

  def self.search(query)
    if ElasticsearchService.enabled?
      elasticsearch_results = ElasticsearchService.search('reviews', query)
      elasticsearch_results.map { |result| new(result) }
    else
      fallback_search(query)
    end
  end

  def self.fallback_search(query)
    begin
      query_string = "SELECT * FROM reviews WHERE content LIKE ? ALLOW FILTERING"
      results = CASSANDRA_SESSION.execute(query_string, arguments: ["%#{query}%"])
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
      book_id: book_id,
      content: content,
      score: score
    }
    ElasticsearchService.index_document('reviews', id, document)
  end

  def delete_from_elasticsearch
    ElasticsearchService.delete_document('reviews', id)
  end

end