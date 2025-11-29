class GiftsController < ApplicationController
  before_action :set_nested_resources
  def index
    @gifts = Gift.all
  end

  def show
    @gift = @gift_list.gifts.find(params[:id])

    # NEW: automatically seed purchase options if we know this gift
    GiftOfferLookupService.new(@gift).ensure_offers!
  end

  def new
    @gift = Gift.new
  end

  def create
    @gift = @gift_list.gifts.new(gift_params)
    if @gift.save
      redirect_to gift_list_path(@gift_list)
      # redirect_to recipient_gift_list_gift_path(@recipient, @gift_list, @gift)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private


  def set_nested_resources
    @gift_list = GiftList.find(params[:gift_list_id])
    @recipient = @gift_list.recipient
  end
  def gift_params
    params.expect(gift: [ :name ])
  end
end
