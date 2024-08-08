class TopRatedBooksController < ApplicationController
  def index
    @top_books = Book.all.map do |book|
      reviews = Review.by_books([book.id])
      avg_score = reviews.any? ? (reviews.sum(&:score).to_f / reviews.count).round(2) : 0
      highest_review = reviews.max_by(&:score)
      lowest_review = reviews.min_by(&:score)
      
      {
        id: book.id,
        name: book.name,
        author: Author.find(book.author_id).name,
        avg_score: avg_score,
        highest_review: highest_review,
        lowest_review: lowest_review
      }
    end.sort_by { |book| -book[:avg_score] }.first(10)
  end
end