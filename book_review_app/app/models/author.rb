class Author < CassandraRecord
  validates :name, presence: true
  def self.create(attributes)
    attributes[:id] ||= Cassandra::Uuid::Generator.new.now
    attributes[:date_of_birth] = attributes[:date_of_birth].to_time if attributes[:date_of_birth].is_a?(Date)
    super(attributes)
  end
end