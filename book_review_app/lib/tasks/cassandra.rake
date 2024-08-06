namespace :cassandra do
  desc "Set up Cassandra schema"
  task setup: :environment do
    keyspace = Rails.application.config_for(:cassandra)['keyspace']
    
    CASSANDRA_CLIENT.connect.execute("CREATE KEYSPACE IF NOT EXISTS #{keyspace} WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }")
    
    CASSANDRA_SESSION.execute("USE #{keyspace}")
    
    CASSANDRA_SESSION.execute("CREATE TABLE IF NOT EXISTS authors (
      id uuid PRIMARY KEY,
      name text,
      date_of_birth timestamp,
      country_of_origin text,
      short_description text
    )")
    
    CASSANDRA_SESSION.execute("CREATE TABLE IF NOT EXISTS books (
      id uuid PRIMARY KEY,
      name text,
      summary text,
      date_of_publication timestamp,
      number_of_sales int
    )")
    
    CASSANDRA_SESSION.execute("CREATE TABLE IF NOT EXISTS reviews (
      id uuid PRIMARY KEY,
      book_id uuid,
      review text,
      score int,
      up_votes int
    )")
    
    CASSANDRA_SESSION.execute("CREATE TABLE IF NOT EXISTS yearly_sales (
      id uuid PRIMARY KEY,
      book_id uuid,
      year int,
      sales int
    )")
    
    puts "Cassandra schema setup completed."
  end
end