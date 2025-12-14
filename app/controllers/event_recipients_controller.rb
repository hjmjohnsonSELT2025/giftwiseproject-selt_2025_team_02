class EventRecipientsController < ApplicationController
  def show
    @event = Event.find(params[:event_id])
    @event_recipient = @event.event_recipients.find(params[:id])
  end
end