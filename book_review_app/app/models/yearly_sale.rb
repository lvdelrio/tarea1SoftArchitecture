class YearlySale < CassandraRecord
  def self.create(attributes)
    attributes[:id] ||= Cassandra::Uuid::Generator.new.now
    super(attributes)
  end

  def self.total_sales_for_book(book_id)
    query = "SELECT SUM(sales) AS total_sales FROM yearly_sales WHERE book_id = ? ALLOW FILTERING"
    result = CASSANDRA_SESSION.execute(query, arguments: [book_id]).first
    result['total_sales'] || 0
  end

  def self.top_5_books_for_year(year)
    query = "SELECT book_id, sales FROM yearly_sales WHERE year = ? LIMIT 5 ALLOW FILTERING"
    results = CASSANDRA_SESSION.execute(query, arguments: [year])
    results.map { |row| row['book_id'] }
  end
end