class RecipientsController < ApplicationController
  def index
    @recipients = current_user.recipients
  end

  def new
    @recipient = Recipient.new
    @from_event  = params[:from_event] == "true"
    @event_id    = params[:event_id]
  end

  def create
    @recipient = current_user.recipients.new(recipient_params)
    @from_event = params[:from_event] == "true"
    @event_id   = params[:event_id]

    if @recipient.save
      if @from_event && @event_id.present?
        # attach to the event and go back to that event
        event = current_user.events.find_by(id: @event_id)

        if event && !event.recipients.include?(@recipient)
          event.recipients << @recipient
        end

        redirect_to event_path(event),
                    notice: "Recipient created and added to event."
      else
        flash[:notice] = "#{@recipient.name} was successfully created."
        redirect_to recipients_path
      end
    else
      render :new, status: :unprocessable_entity
    end
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
