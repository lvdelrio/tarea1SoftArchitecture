class ReviewsController < ApplicationController
  def index
    @reviews = Review.all
    render json: @reviews
  end

  def show
    @review = Review.cached_find(params[:id])
    if @review
      render json: @review
    else
      render json: { error: "Review not found" }, status: :not_found
    end
  end

  def create
    @review = Review.create(review_params)
    if @review
      # Clear the average score cache for the associated book
      Rails.cache.delete("avg_score_book_#{@review.book_id}")
      render json: @review, status: :created
    else
      render json: { error: "Failed to create review" }, status: :unprocessable_entity
    end
  end

  def update
    @review = Review.find(params[:id])
    if @review.update(review_params)
      # Clear caches
      Review.clear_cache(@review.id.to_s)
      Rails.cache.delete("avg_score_book_#{@review.book_id}")
      render json: @review
    else
      render json: { error: "Failed to update review" }, status: :unprocessable_entity
    end
  end

  def destroy
    @review = Review.find(params[:id])
    book_id = @review.book_id
    if @review.destroy
      # Clear caches
      Review.clear_cache(@review.id.to_s)
      Rails.cache.delete("avg_score_book_#{book_id}")
      head :no_content
    else
      render json: { error: "Failed to delete review" }, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:review).permit(:book_id, :review, :score, :up_votes)
  end
end