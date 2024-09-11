class BookIndex
    INDEX_NAME = 'books'

    def self.index_name
      "#{Rails.env}_#{INDEX_NAME}"
    end

    def self.create_index
      ELASTICSEARCH_CLIENT.indices.create(
        index: index_name,
        body: {
          mappings: {
            properties: {
              id: { type: 'keyword' },
              name: { type: 'text' },
              summary: { type: 'text' },
              author_id: { type: 'keyword' },
              date_of_publication: { type: 'date' }
            }
          }
        }
      )
    end

    def self.delete_index
        ELASTICSEARCH_CLIENT.indices.delete(index: index_name)
      end
  
    def self.index_document(book)
    ELASTICSEARCH_CLIENT.index(
        index: index_name,
        id: book.id,
        body: {
        id: book.id,
        name: book.name,
        summary: book.summary,
        author_id: book.author_id,
        date_of_publication: book.date_of_publication
        }
    )
    end