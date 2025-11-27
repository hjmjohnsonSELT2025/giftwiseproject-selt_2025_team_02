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
    ai_output = AiGiftService.new(@recipient)
    # if the AI has cached suggestions, then show them automatically
    @suggestions_exist = ai_output.has_cached_suggestions?
    if @suggestions_exist
      @suggestions = ai_output.suggest_gift
    end
  end

  def generate_gift
    @recipient = current_user.recipients.find(params[:id])
    # if the user clicked on the "Generate new ideas" button then generate new ones instead of showing the cached ones
    should_refresh = params[:refresh] == "true"
    begin
      ai_service = AiGiftService.new(@recipient, force_refresh: should_refresh)
      @suggestions = ai_service.suggest_gift
      @suggestions_exist = true
      if @suggestions.is_a?(Hash) && @suggestions.key?("Error")
        flash.now[:alert] = @suggestions["Error"]
        @suggestions = nil
        @suggestions_exist = false
      else
        @suggestions_exist = true
      end
    rescue StandardError => e
      flash.now[:alert] = "Could not generate gifts. Please try again later."
      @suggestions = nil
      @suggestions_exist = false
    end
    render :show
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
