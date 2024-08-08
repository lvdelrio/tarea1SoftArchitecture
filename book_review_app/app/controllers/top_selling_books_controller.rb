class TopSellingBooksController < ApplicationController
  def index
    @top_books = Book.all.map do |book|
      author = Author.find(book.author_id)
      total_sales = YearlySale.total_sales_for_book(book.id)
      author_total_sales = Book.by_author(book.author_id).sum { |b| YearlySale.total_sales_for_book(b.id) }
      publication_year = book.date_of_publication.year
      top_5_that_year = YearlySale.top_5_books_for_year(publication_year).include?(book.id)

      {
        id: book.id,
        name: book.name,
        author: author.name,
        total_sales: total_sales,
        author_total_sales: author_total_sales,
        publication_year: publication_year,
        top_5_that_year: top_5_that_year
      }
    end.sort_by { |book| -book[:total_sales] }.first(50)
  end
end