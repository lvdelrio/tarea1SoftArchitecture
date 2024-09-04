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
    @book = Book.create(book_params)
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
  
  def new
    @book = Book.new
    @authors = Author.all
  end

  def create
    @book = Book.new(book_params)
    
    if params[:author][:name].present?
      @author = Author.create(author_params)
      @book.author_id = @author.id
    end

    if @book.save
      redirect_to books_path, notice: 'Book was successfully created.'
    else
      @authors = Author.all
      render :new
    end
  end

  private

  def book_params
    params.require(:book).permit(:name, :summary, :date_of_publication, :number_of_sales, :author_id)
  end

  def author_params
    params.require(:author).permit(:name, :date_of_birth, :country_of_origin, :short_description)
  end
end