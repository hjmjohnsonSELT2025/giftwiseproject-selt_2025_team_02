class RecipientsController < ApplicationController
  def index
    @recipients = current_user.recipients
  end

  def new
    @recipient = Recipient.new
  end

  def create
    @recipient = current_user.recipients.create!(recipient_params)
    flash[:notice] = "#{@recipient.name} was successfully created."
    redirect_to recipients_path
  end

  def edit
    @recipient = current_user.recipients.find(params[:id])
  end

  def update
    @recipient = current_user.recipients.find(params[:id])
    @recipient.update!(recipient_params)
    flash[:notice] = "#{@recipient.name} was successfully updated."
    redirect_to recipient_path(@recipient)
  end

  def show
    @recipient = current_user.recipients.find(params[:id])
  end

  def destroy
    @recipient = current_user.recipients.find(params[:id])
    @recipient.destroy
    flash[:notice] = "Recipient '#{@recipient.name}' deleted."
    redirect_to recipients_path
  end

  private

  def recipient_params
    params.require(:recipient).permit(:name, :age, :gender, :relation, likes: [], dislikes: [])
  end
end
