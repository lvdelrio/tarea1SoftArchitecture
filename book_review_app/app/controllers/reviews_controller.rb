class ReviewsController < ApplicationController
  def index
    @reviews = Review.all
    render json: @reviews
  end

  #CRUD Reviews
  def show
    @review = Review.find(params[:id])
    render json: @review
  end

  def create
    @review = Review.create(review_params)
    if @review
      render json: @review, status: :created
    else
      render json: { error: "Failed to create review" }, status: :unprocessable_entity
    end
  end

  def update
    @review = Review.find(params[:id])
    if @review.update(review_params)
      render json: @review
    else
      render json: { error: "Failed to update review" }, status: :unprocessable_entity
    end
  end

  def destroy
    @review = Review.find(params[:id])
    if @review.destroy
      head :no_content
    else
      render json: { error: "Failed to delete review" }, status: :unprocessable_entity
    end
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new(review_params)

    if @review.save
      redirect_to @review, notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  private

  def review_params
    params.require(:review).permit(:book_id, :review, :score)
  end
end