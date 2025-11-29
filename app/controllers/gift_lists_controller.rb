class GiftListsController < ApplicationController
  # before_action :set_recipient
  def index
  end

  def new
    @gift_list = GiftList.new
  end
  def show
    @gift_list = GiftList.find(params[:id])
  end

  def create
    @gift_list = current_user.gift_lists.new(gift_list_params)
    if @gift_list.save
      redirect_to gift_lists_path
    else
      flash[:error] = "Could not create gift list"
      render :new, status: :unprocessable_entity
    end
  end



  # def set_recipient
  #   @recipient = Recipient.find(params[:recipient_id])
  # end

  def gift_list_params
    params.require(:gift_list).permit(:name, :recipient_id)
  end

end
