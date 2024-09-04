require 'cassandra'
require 'yaml'
require 'erb'

namespace :cassandra do
  desc "Reset and set up Cassandra schema"
  task :setup do
    yaml_content = ERB.new(File.read('config/cassandra.yml')).result
    config = YAML.safe_load(yaml_content, aliases: true)['development']
    keyspace = ENV['CASSANDRA_KEYSPACE'] || config['keyspace']
    hosts = ENV['CASSANDRA_HOST'] ? [ENV['CASSANDRA_HOST']] : config['hosts']
    port = config['port']

    cluster = Cassandra.cluster(hosts: hosts, port: port)
    session = cluster.connect

    begin
      # Drop the keyspace if it exists
      session.execute("DROP KEYSPACE IF EXISTS #{keyspace}")
      puts "Dropped keyspace #{keyspace} if it existed."

      # Create the keyspace
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
        author_id uuid,
        name text,
        summary text,
        date_of_publication timestamp,
        number_of_sales bigint
      )")
      
      session.execute("CREATE TABLE reviews (
        id uuid PRIMARY KEY,
        book_id uuid,
        review text,
        score bigint,
        up_votes bigint
      )")
      
      session.execute("CREATE TABLE yearly_sales (
        id uuid PRIMARY KEY,
        book_id uuid,
        year bigint,
        sales bigint
      )")
      
      puts "Cassandra schema reset and setup completed."
    rescue Cassandra::Errors::NoHostsAvailable => e
      puts "Failed to connect to Cassandra: #{e.message}"
      puts "Hosts: #{hosts}"
      puts "Port: #{port}"
      raise
    ensure
      cluster.close if cluster
    end
  end
end