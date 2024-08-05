require 'cassandra'

module CassandraConnection
  def self.client
    @client ||= Cassandra.cluster(
      hosts: ['127.0.0.1'],
      port: 9042
    )
  end

  def self.session
    @session ||= client.connect('book_review_development')
  end
end