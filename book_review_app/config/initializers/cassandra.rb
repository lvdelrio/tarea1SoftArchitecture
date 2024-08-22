require 'cassandra'

cassandra_config = Rails.application.config_for(:cassandra)

CASSANDRA_CLIENT = Cassandra.cluster(
  hosts: cassandra_config['hosts'],
  port: cassandra_config['port']
)

# Attempt to connect to the keyspace, create it if it doesn't exist
begin
  CASSANDRA_SESSION = CASSANDRA_CLIENT.connect(cassandra_config['keyspace'])
rescue Cassandra::Errors::InvalidError
  # Keyspace doesn't exist, create it
  session = CASSANDRA_CLIENT.connect
  session.execute("CREATE KEYSPACE IF NOT EXISTS #{cassandra_config['keyspace']} WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 }")
  CASSANDRA_SESSION = CASSANDRA_CLIENT.connect(cassandra_config['keyspace'])
end