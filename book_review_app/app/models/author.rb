class Author
  include Cequel::Record
  
  key :id, :timeuuid, auto: true
  column :name, :text
  column :date_of_birth, :timestamp
  column :country_of_origin, :text
  column :description, :text
end