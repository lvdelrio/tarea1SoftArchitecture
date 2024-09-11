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
    begin
      @author = Author.cached_find(params[:id].to_s)
      if @author
        respond_to do |format|
          format.html
          format.json { render json: @author }
        end
      else
        respond_to do |format|
          format.html { redirect_to authors_url, alert: 'Author not found.' }
          format.json { render json: { error: "Author not found" }, status: :not_found }
        end
      end
    rescue ArgumentError => e
      respond_to do |format|
        format.html { redirect_to authors_url, alert: 'Invalid author ID.' }
        format.json { render json: { error: "Invalid author ID" }, status: :bad_request }
      end
    end
  end

  def new
    @author = Author.new
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
      Rails.cache.delete("author_name_#{@author.name}")
      respond_to do |format|
        format.html { redirect_to @author, notice: 'Author was successfully created.' }
        format.json { render json: @author, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { error: "Failed to create author" }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @author = Author.find(params[:id])
    if @author.nil?
      redirect_to authors_url, alert: 'Author not found or invalid ID.'
    end
  rescue StandardError => e
    Rails.logger.error "Error in edit action: #{e.message}"
    redirect_to authors_url, alert: 'An error occurred while trying to edit the author.'
  end

  def update
    @author = Author.find(params[:id])
    old_name = @author.name
    if @author.update(author_params)
      # Clear caches
      Author.clear_cache(@author.id.to_s)
      Rails.cache.delete("author_name_#{old_name}")
      Rails.cache.delete("author_name_#{@author.name}")
      respond_to do |format|
        format.html {redirect_to @author, notice: 'Author was successfully updated.'}
        format.json { render json: @author }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { error: "Failed to update author" }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @author = Author.find(params[:id])
    if @author.destroy
      # Clear caches
      Author.clear_cache(@author.id.to_s)
      Rails.cache.delete("author_name_#{@author.name}")
      respond_to do |format|
        format.html { redirect_to authors_url, notice: 'Author was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to authors_url, alert: 'Failed to delete author.' }
        format.json { render json: { error: "Failed to delete author" }, status: :unprocessable_entity }
      end
    end
  end

  private

  def author_params
    params.require(:author).permit(:name, :date_of_birth, :country_of_origin, :short_description)
  end
end