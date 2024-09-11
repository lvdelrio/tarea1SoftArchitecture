class ElasticsearchService
  def self.elasticsearch_url
    ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'
  end
  
  def self.client
    @client ||= Elasticsearch::Client.new(url: elasticsearch_url)
  end

  def self.enabled?
    @enabled ||= begin
      client.ping
      true
    rescue Faraday::ConnectionFailed
      false
    end
  end
end