class GiftListsController < ApplicationController
  # before_action :set_recipient
  def index
  end

  def new
    @gift_list = GiftList.new
  end
  def show
    @gift_list = GiftList.find(params[:id])
    # makes recipient available to show view
    @recipient = @gift_list.recipient
  end

  def create
    @gift_list = current_user.gift_lists.new(gift_list_params)
    if @gift_list.save
      redirect_to recipient_path(@gift_list.recipient), notice: "List created successfully!"
    else
      flash[:error] = "Could not create gift list"
      # if gift list creation fails then reload events
      @events = @gift_list.recipient&.events || []
    end
  end

  # def set_recipient
  #   @recipient = Recipient.find(params[:recipient_id])
  # end

  def gift_list_params
    params.require(:gift_list).permit(:name, :recipient_id, :event_id)
  end
end
