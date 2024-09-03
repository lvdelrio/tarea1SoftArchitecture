class BooksController < ApplicationController
  def index
    begin
      @books = Book.all

      if params[:search].present?
        @books = Book.search(params[:search])
      end

      if params[:author_id].present?
        @books = @books.select { |book| book.author_id.to_s == params[:author_id] }
      end

      if params[:publication_date_start].present? && params[:publication_date_end].present?
        start_date = Date.parse(params[:publication_date_start])
        end_date = Date.parse(params[:publication_date_end])
        @books = @books.select { |book| book.date_of_publication.to_date.between?(start_date, end_date) }
      end

      if params[:min_rating].present?
        @books = @books.select do |book|
          avg_score = Review.average_score_for_book(book.id)
          avg_score >= params[:min_rating].to_f
        end
      end

      @books = @books.map do |book|
        author = Author.find(book.author_id)
        {
          id: book.id,
          name: book.name,
          author_name: author.name,
          date_of_publication: book.date_of_publication,
          average_rating: Review.average_score_for_book(book.id),
          number_of_sales: book.number_of_sales
        }
      end

      respond_to do |format|
        format.html
        format.json { render json: @books }
      end
    rescue => e
      Rails.logger.error "Error in BooksController#index: #{e.message}"
      respond_to do |format|
        format.html { render plain: "An error occurred while processing your request.", status: :internal_server_error }
        format.json { render json: { error: "An error occurred while processing your request." }, status: :internal_server_error }
      end
    end
  end
end