class YearlySalesController < ApplicationController
  def index
    @yearly_sales = YearlySale.all
    render json: @yearly_sales
  end

  def show
    @yearly_sale = YearlySale.find(params[:id])
    render json: @yearly_sale
  end

  def create
    @yearly_sale = YearlySale.create(yearly_sale_params)
    if @yearly_sale
      render json: @yearly_sale, status: :created
    else
      render json: { error: "Failed to create yearly sale" }, status: :unprocessable_entity
    end
  end

  def update
    @yearly_sale = YearlySale.find(params[:id])
    if @yearly_sale.update(yearly_sale_params)
      render json: @yearly_sale
    else
      render json: { error: "Failed to update yearly sale" }, status: :unprocessable_entity
    end
  end

  def destroy
    @yearly_sale = YearlySale.find(params[:id])
    if @yearly_sale.destroy
      head :no_content
    else
      render json: { error: "Failed to delete yearly sale" }, status: :unprocessable_entity
    end
  end

  private

  def yearly_sale_params
    params.require(:yearly_sale).permit(:book_id, :year, :sales)
  end
end