class GiftListsController < ApplicationController
  def index
    @gift_list = GiftList.all
  end

  def show
    @gift_list = GiftList.find(params[:id])

  end
end
