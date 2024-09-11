module Searchable
    extend ActiveSupport::Concern
  
    included do
      include Elasticsearch::Model
  
      # Configure Elasticsearch settings and mappings here
      settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
          # Define your mappings here
        end
      end
  
      # Define what attributes should be searchable
      def as_indexed_json(options = {})
        as_json(only: searchable_fields)
      end
      
      def self.search(index, query)
        return [] unless enabled?
        response = client.search(index: index, body: {
          query: {
            multi_match: {
              query: query,
              fields: ['name^2', 'summary', 'content']
            }
          }
        })
        response['hits']['hits'].map { |hit| hit['_source'] }
      end
    end
  
      # Callbacks to keep Elasticsearch index in sync
      after_commit on: [:create] do
        __elasticsearch__.index_document if ElasticsearchService.enabled?
      end
  
      after_commit on: [:update] do
        __elasticsearch__.update_document if ElasticsearchService.enabled?
      end
  
      after_commit on: [:destroy] do
        __elasticsearch__.delete_document if ElasticsearchService.enabled?
      end
    end
  
    class_methods do
      def searchable_fields
        # Override this method in each model to define searchable fields
        []
      end
  
      def fallback_search(query)
        # Override this method in each model to define fallback search behavior
        []
      end
    end
  end