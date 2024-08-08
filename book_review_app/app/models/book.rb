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
end