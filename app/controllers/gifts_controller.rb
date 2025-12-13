class GiftsController < ApplicationController
  before_action :set_nested_resources, except: [ :index, :refresh_offers ]
  before_action :set_gift_for_member_actions, only: [ :refresh_offers ]
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

  def refresh_offers
    #@gift is set in set_gift_for_member_actions

    GiftOfferLookupService.new(@gift).ensure_offers!(force: true)

    redirect_back fallback_location: recipient_gift_list_path(@recipient, @gift_list, @gift),
                  notice: "Gift offers refreshed."
  rescue StandardError => e
    Rails.logger.error("Refresh offers failed for gift_id=#{params[:id]}: #{e.class} - #{e.message}")

    redirect_back fallback_location: recipient_gift_list_gift_path(@recipient, @gift_list, @gift),
                  alert: "Could not refresh offers right now."
  end

  private


  def set_nested_resources
    @gift_list = GiftList.find(params[:gift_list_id])
    @recipient = @gift_list.recipient
  end
  def set_gift_for_member_actions
    @gift = Gift.find(params[:id])
    @gift_list = @gift.gift_list
    @recipient = @gift_list.recipient
  end
  def gift_params
    params.expect(gift: [ :name ])
  end
end
