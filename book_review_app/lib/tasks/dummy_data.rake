namespace :dummy_data do
  desc "Create dummy data for authors, books, reviews, and yearly sales"
  task create: :environment do
    require 'faker'
  
    puts "Creating dummy authors..."
    authors = 50.times.map do
      author = Author.create(
        name: Faker::Name.name,
        date_of_birth: Faker::Date.between(from: 100.years.ago, to: 18.years.ago).to_time,
        country_of_origin: Faker::Address.country,
        short_description: Faker::Lorem.paragraph(sentence_count: 2)
      )
      author
    end

    puts "\nCreating dummy books..."
    books = 100.times.map do
      book = Book.create(
        name: Faker::Book.title,
        summary: Faker::Lorem.paragraph(sentence_count: 3),
        date_of_publication: Faker::Date.between(from: 50.years.ago, to: Date.today).to_time,
        number_of_sales: Faker::Number.between(from: 1000, to: 1000000).to_i
      )
      book
    end

    # puts "\nCreating dummy reviews..."
    # books.each do |book|
    #   rand(1..10).times do
    #     review = Review.create(

    #       book_id: book.id,
    #       review: Faker::Lorem.paragraph(sentence_count: 2),
    #       score: Faker::Number.between(from: 1, to: 5),
    #       up_votes: Faker::Number.between(from: 0, to: 1000)
    #     )
    #     puts "Created review for #{book.name}"
    #   end
    # end

    # puts "\nCreating dummy yearly sales..."
    # books.each do |book|
    #   publication_year = book.date_of_publication.year
    #   (publication_year..Date.today.year).each do |year|
    #     yearly_sale = YearlySale.create(

    #       book_id: book.id,
    #       year: year,
    #       sales: Faker::Number.between(from: 100, to: 100000)
    #     )
    #     puts "Created yearly sale for #{book.name} in #{year}"
    #   end
    # end

    # puts "\nDummy data creation completed!"
  end
end