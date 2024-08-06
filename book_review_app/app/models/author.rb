class Author < CassandraRecord
  def self.create(attributes)
    attributes[:id] ||= SecureRandom.uuid
    super(attributes)
  end
end