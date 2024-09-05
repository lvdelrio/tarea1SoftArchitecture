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
  # CRUD BOOKS
  def show
    @book = Book.find(params[:id])
    render json: @book
  end

  def create
    book_attributes = book_params.to_h
    book_attributes[:date_of_publication] = book_attributes[:date_of_publication].to_time if book_attributes[:date_of_publication]
    book_attributes[:name] = book_attributes[:name].to_s
    book_attributes[:summary] = book_attributes[:summary].to_s
    book_attributes[:number_of_sales] = book_attributes[:number_of_sales].to_i
    
    author_name = book_attributes.delete(:author_name)
    
    if author_name.blank?
      render json: { error: "Author name cannot be blank" }, status: :unprocessable_entity
      return
    end

    author = Author.find_by_name(author_name)
    
    if author.nil?
      render json: { error: "Author not found: #{author_name}" }, status: :unprocessable_entity
      return
    end

    book_attributes[:author_id] = author.id
    @book = Book.create(book_attributes)
    
    if @book
      render json: @book, status: :created
    else
      render json: { error: "Failed to create book" }, status: :unprocessable_entity
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      render json: @book
    else
      render json: { error: "Failed to update book" }, status: :unprocessable_entity
    end
  end

  def destroy
    @book = Book.find(params[:id])
    if @book.destroy
      head :no_content
    else
      render json: { error: "Failed to delete book" }, status: :unprocessable_entity
    end
  end

  private

  def book_params
    params.require(:book).permit(:name, :author_name, :summary, :date_of_publication, :number_of_sales)
  end
end