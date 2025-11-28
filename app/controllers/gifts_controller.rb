class GiftsController < ApplicationController
  before_action :init
  def index
    @gifts = Gift.all
  end

  def show
    @gift = @gift_list.gifts.find(params[:id])
  end

  def new
    @gift = Gift.new
  end

  def create
    @gift = @gift_list.gifts.new(gift_params)
    if @gift.save
      redirect_to recipient_gift_list_path(@recipient, @gift_list)
      # redirect_to recipient_gift_list_gift_path(@recipient, @gift_list, @gift)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def init
    @gift_list = GiftList.find(params[:gift_list_id])
    @recipient = Recipient.find(params[:recipient_id])
  end
  def gift_params
    params.expect(gift: [ :name ])
  end
end
