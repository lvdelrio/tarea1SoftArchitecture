class Book
    include Cequel::Record
    
    key :id, :timeuuid, auto: true
    column :title, :text
    column :author, :text
    column :summary, :text
    column :publication_date, :timestamp
    column :sales, :int
  end