class GiftsController < ApplicationController
  def index
    @gifts = Gift.all
  end

  def show

    @gift = Gift.find(params[:id])
  end
end
