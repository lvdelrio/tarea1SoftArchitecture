class Author < CassandraRecord
  def self.create(attributes)
    attributes[:id] ||= SecureRandom.uuid
    attributes[:date_of_birth] = attributes[:date_of_birth].to_time if attributes[:date_of_birth].is_a?(Date)
    super(attributes)
  end
end