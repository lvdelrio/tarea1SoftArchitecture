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

end