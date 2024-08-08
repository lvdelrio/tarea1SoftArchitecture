class AuthorsController < ApplicationController
  def index
    @authors = Author.all.map do |author|
      books = Book.by_author(author.id)
      book_ids = books.map(&:id)
      reviews = Review.by_books(book_ids)

      {
        id: author.id,
        name: author.name,
        book_count: books.count,
        avg_score: reviews.any? ? (reviews.sum(&:score).to_f / reviews.count).round(2) : nil,
        total_sales: books.sum(&:number_of_sales)
      }
    end

    respond_to do |format|
      format.html
      format.json { render json: @authors }
    end
  end
  def destroy
    @author = Author.find(params[:id])
    Book.by_author(@author.id).each do |book|
      Book.delete(book.id)
    end
    
    @author.destroy

    respond_to do |format|
      format.html { redirect_to authors_url, notice: 'Author was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end