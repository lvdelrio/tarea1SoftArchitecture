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

  def show
    @author = Author.cached_find(params[:id])
    if @author
      render json: @author
    else
      render json: { error: "Author not found" }, status: :not_found
    end
  end

  def create
    author_attributes = author_params.to_h
    author_attributes[:id] = Cassandra::Uuid::Generator.new.now
    author_attributes[:date_of_birth] = author_attributes[:date_of_birth].to_time if author_attributes[:date_of_birth]
    author_attributes[:name] = author_attributes[:name].to_s
    author_attributes[:country_of_origin] = author_attributes[:country_of_origin].to_s
    author_attributes[:short_description] = author_attributes[:short_description].to_s
    
    @author = Author.create(author_attributes)
    if @author
      # Clear the cache for find_by_name
      Rails.cache.delete("author_name_#{@author.name}")
      render json: @author, status: :created
    else
      render json: { error: "Failed to create author" }, status: :unprocessable_entity
    end
  end

  def update
    @author = Author.find(params[:id])
    old_name = @author.name
    if @author.update(author_params)
      # Clear caches
      Author.clear_cache(@author.id.to_s)
      Rails.cache.delete("author_name_#{old_name}")
      Rails.cache.delete("author_name_#{@author.name}")
      render json: @author
    else
      render json: { error: "Failed to update author" }, status: :unprocessable_entity
    end
  end

  def destroy
    @author = Author.find(params[:id])
    if @author.destroy
      # Clear caches
      Author.clear_cache(@author.id.to_s)
      Rails.cache.delete("author_name_#{@author.name}")
      head :no_content
    else
      render json: { error: "Failed to delete author" }, status: :unprocessable_entity
    end
  end

  private

  def author_params
    params.require(:author).permit(:name, :date_of_birth, :country_of_origin, :short_description)
  end
end