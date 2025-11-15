class GiftsController < ApplicationController
  def index
    @gifts = Gift.all
  end

  def show
    @gift = Gift.find(params[:id])
  end

  def new
    @gift = Gift.new
  end

  def create
    @gift = Gift.new(gift_params)
    @gift.user_id = @current_user.id.to_s
    if @gift.save
      redirect_to @gift
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def gift_params
    params.expect(gift: [ :name ])
  end
end
