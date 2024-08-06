require 'cassandra'

cassandra_config = Rails.application.config_for(:cassandra)

CASSANDRA_CLIENT = Cassandra.cluster(
  hosts: cassandra_config['hosts'],
  port: cassandra_config['port']
)

CASSANDRA_SESSION = CASSANDRA_CLIENT.connect(cassandra_config['keyspace'])