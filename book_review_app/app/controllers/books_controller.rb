class BooksController < ApplicationController
  def index
    cache_key = "books_index_#{params.to_s}"
    @books = Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
      books = Book.all
  
      # Apply filters...
      if params[:search].present?
        books = Book.search(params[:search])
      end
  
      if params[:author_id].present?
        books = books.select { |book| book.author_id.to_s == params[:author_id] }
      end
  
      if params[:publication_date_start].present? && params[:publication_date_end].present?
        start_date = Date.parse(params[:publication_date_start])
        end_date = Date.parse(params[:publication_date_end])
        books = books.select { |book| book.date_of_publication.to_date.between?(start_date, end_date) }
      end
  
      if params[:min_rating].present?
        books = books.select do |book|
          avg_score = Review.average_score_for_book(book.id)
          avg_score >= params[:min_rating].to_f
        end
      end
  
      books.map do |book|
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
  
  # CRUD BOOKS
  def show
    @book = Book.cached_find(params[:id])
    @reviews_count = @book.cached_reviews_count
    
    respond_to do |format|
      format.html 
      format.json { render json: @book }
    end
  end

  def new
    @book = Book.new
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
    
    # Handle cover image upload
    if params[:book][:cover_image].present?
      uploaded_file = params[:book][:cover_image]
      file_name = "#{SecureRandom.uuid}_#{uploaded_file.original_filename}"
      file_path = Rails.root.join('public', 'uploads', file_name)
      File.open(file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end
      book_attributes[:cover_image_url] = "/uploads/#{file_name}"
    end
    
    @book = Book.create(book_attributes)
  
    if @book
      Rails.cache.delete("books_index_#{params.to_s}")  # Invalidate index cache
      respond_to do |format|
        format.html { redirect_to @book, notice: 'Book was successfully created.' }
        format.json { render json: @book, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { error: "Failed to create book" }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    book_attributes = book_params.to_h
    
    # Handle cover image upload
    if params[:book][:cover_image].present?
      uploaded_file = params[:book][:cover_image]
      file_name = "#{SecureRandom.uuid}_#{uploaded_file.original_filename}"
      file_path = Rails.root.join('public', 'uploads', file_name)
      File.open(file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end
      book_attributes[:cover_image_url] = "/uploads/#{file_name}"
      
      # Delete old image file if it exists
      if @book.cover_image_url.present?
        old_file_path = Rails.root.join('public', @book.cover_image_url.sub(/^\//, ''))
        File.delete(old_file_path) if File.exist?(old_file_path)
      end
    end
    
    if @book.update(book_attributes)
      Rails.cache.delete("book_#{@book.id}")
      Rails.cache.delete("book_#{@book.id}_reviews_count")
      respond_to do |format|
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { render json: @book }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { error: "Failed to update book" }, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @book = Book.find(params[:id])
    if @book.destroy
      Rails.cache.delete("book_#{@book.id}")
      Rails.cache.delete("book_#{@book.id}_reviews_count")
      Rails.cache.delete("books_index_#{params.to_s}")  # Invalidate index cache
      respond_to do |format|
        format.html { redirect_to books_url, notice: 'Book was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to books_url, alert: 'Failed to delete book.' }
        format.json { render json: { error: "Failed to delete book" }, status: :unprocessable_entity }
      end
    end
  end

  private

  def book_params
    params.require(:book).permit(:name, :author_name, :summary, :date_of_publication, :number_of_sales, :cover_image)
  end
end