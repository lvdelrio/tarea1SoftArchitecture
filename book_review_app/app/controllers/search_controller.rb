class SearchController < ApplicationController
    def index
      @query = params[:q]
      @books = Book.search(@query)
      @reviews = Review.search(@query)
  
      respond_to do |format|
        format.html
        format.json { render json: { books: @books, reviews: @reviews } }
      end
    end
  ends