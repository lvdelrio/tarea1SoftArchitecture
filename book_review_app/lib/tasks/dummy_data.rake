namespace :dummy_data do
  desc "Create dummy data for books and reviews"
  task create: :environment do
    require 'faker'

    puts "Creating dummy books..."
    20.times do
      book = Book.create!(
        title: Faker::Book.title,
        author: Faker::Book.author,
        summary: Faker::Lorem.paragraph,
        publication_date: Faker::Date.between(from: 50.years.ago, to: Date.today),
        sales: Faker::Number.between(from: 1000, to: 1000000)
      )
      puts "Created book: #{book.title}"

      rand(1..5).times do
        review = Review.create!(
          book_id: book.id,
          reviewer: Faker::Name.name,
          content: Faker::Lorem.paragraph,
          rating: Faker::Number.between(from: 1, to: 5),
          upvotes: Faker::Number.between(from: 0, to: 100)
        )
        puts "  Created review for #{book.title}"
      end
    end

    puts "Dummy data creation completed!"
  end
end