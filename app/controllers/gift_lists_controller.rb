class GiftListsController < ApplicationController
  before_action :set_recipient
  def index
    @recipient = Recipient.find(params[:recipient_id])
    @gift_lists = @recipient.gift_lists
  end

  def new
    @recipient = Recipient.find(params[:recipient_id])
    @gift_list = @recipient.gift_lists.new
  end
  def show
    @gift_list = GiftList.find(params[:id])
  end

  def create
    @gift_list = @recipient.gift_lists.new(gift_list_params)
    #@gift.user_id = @current_user.id.to_s
    if @gift_list.save
      redirect_to recipient_gift_lists_path(@recipient)
    else
      render :new, status: :unprocessable_entity
    end
  end



  def set_recipient
    @recipient = Recipient.find(params[:recipient_id])
  end

  def gift_list_params
    params.expect(gift_list: [ :name ])
  end
end
