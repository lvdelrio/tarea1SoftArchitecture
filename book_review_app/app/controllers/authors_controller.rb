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
  #CDUD AUTHORS
  def show
    @author = Author.find(params[:id])
    render json: @author
  end

  def create
    @author = Author.create(author_params)
    if @author
      render json: @author, status: :created
    else
      render json: { error: "Failed to create author" }, status: :unprocessable_entity
    end
  end

  def update
    @author = Author.find(params[:id])
    if @author.update(author_params)
      render json: @author
    else
      render json: { error: "Failed to update author" }, status: :unprocessable_entity
    end
  end

  def destroy
    @author = Author.find(params[:id])
    if @author.destroy
      head :no_content
    else
      render json: { error: "Failed to delete author" }, status: :unprocessable_entity
    end
  end
  
  def new
    @author = Author.new
  end

  def create
    @author = Author.new(author_params)

    if @author.save
      redirect_to @author, notice: 'Author was successfully created.'
    else
      render :new
    end
  end


  private

  def author_params
    params.require(:author).permit(:name, :date_of_birth, :country_of_origin, :short_description)
  end
end