namespace :cassandra do
  desc "Reset and set up Cassandra schema"
  task setup: :environment do
    config = Rails.application.config_for(:cassandra)
    keyspace = config['keyspace']
    
    cluster = Cassandra.cluster(hosts: config['hosts'], port: config['port'])
    session = cluster.connect
    session.execute("DROP KEYSPACE IF EXISTS #{keyspace}")
    puts "Dropped keyspace #{keyspace} if it existed."

    session.execute("CREATE KEYSPACE #{keyspace} WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }")
    puts "Created keyspace #{keyspace}."

    session.execute("USE #{keyspace}")
    
    # Create tables
    session.execute("CREATE TABLE authors (
      id uuid PRIMARY KEY,
      name text,
      date_of_birth timestamp,
      country_of_origin text,
      short_description text
    )")
    
    session.execute("CREATE TABLE books (
      id uuid PRIMARY KEY,
      name text,
      summary text,
      date_of_publication timestamp,
      number_of_sales int
    )")
    
    session.execute("CREATE TABLE reviews (
      id uuid PRIMARY KEY,
      book_id uuid,
      review text,
      score int,
      up_votes int
    )")
    
    session.execute("CREATE TABLE yearly_sales (
      id uuid PRIMARY KEY,
      book_id uuid,
      year int,
      sales int
    )")
    
    puts "Cassandra schema reset and setup completed."
  end
end