class Sale
  include Cequel::Record
  
  key :book_id, :timeuuid
  key :year, :int
  column :sales, :int
end