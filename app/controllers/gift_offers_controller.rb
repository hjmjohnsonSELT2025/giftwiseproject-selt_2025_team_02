class GiftOffersController < ApplicationController
  before_action :set_context

  def new
    @gift_offer = @gift.gift_offers.new
  end

  def create
    @gift_offer = @gift.gift_offers.new(gift_offer_params)

    if @gift_offer.save
      redirect_to recipient_gift_list_gift_path(@recipient, @gift_list, @gift),
                  notice: "Purchase option was successfully added."
    else
      flash.now[:warning] = "There was a problem adding this purchase option."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_context
    # Scope everything to the logged-in user for safety
    @recipient = current_user.recipients.find(params[:recipient_id])
    @gift_list = @recipient.gift_lists.find(params[:gift_list_id])
    @gift      = @gift_list.gifts.find(params[:gift_id])
  end

  def gift_offer_params
    params.require(:gift_offer).permit(:store_name, :price, :currency, :url, :rating)
  end
end
