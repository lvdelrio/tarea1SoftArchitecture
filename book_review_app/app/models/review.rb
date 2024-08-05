class Review
  include Cequel::Record
  
  key :id, :timeuuid, auto: true
  key :book_id, :timeuuid
  column :review_text, :text
  column :score, :int
  column :up_votes, :int
end