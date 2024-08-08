class YearlySale < CassandraRecord
  def self.create(attributes)
    attributes[:id] ||= Cassandra::Uuid::Generator.new.now
    super(attributes)
  end
end