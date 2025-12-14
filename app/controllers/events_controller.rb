class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy add_recipient remove_recipient]
  before_action :find_optional_recipient, only: %i[new create]

  def index
    @events = current_user.events.order(event_date: :asc, event_time: :asc)
  end

  def show
    @available_recipients = current_user.recipients.where.not(id: @event.recipient_ids)
  end

  def new
    @event = current_user.events.new
  end

  def create
    @event = current_user.events.new(event_params)

    if @event.save
      connect_recipient_and_create_list(@optional_recipient)
      redirect_to @event, notice: "Event '#{@event.name}' successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event '#{@event.name}' successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @event.name
    @event.destroy
    redirect_to events_path, notice: "Event '#{name}' deleted."
  end

  def add_recipient
    recipient = current_user.recipients.find(params[:recipient_id])
    connect_recipient_and_create_list(recipient)
    redirect_to event_path(@event),
                notice: "Recipient '#{recipient.name}' successfully added to '#{@event.name}'."
  end

  def remove_recipient
    recipient = @event.recipients.find(params[:recipient_id])
    @event.recipients.delete(recipient)
    redirect_to event_path(@event),
                notice: "Recipient '#{recipient.name}' successfully removed from '#{@event.name}'."
  end

  private

  def find_optional_recipient
    target_id = params[:recipient_id]
    if target_id.blank? && params[:event]
      target_id = params[:event][:recipient_id]
    end
    if target_id.present?
      @optional_recipient = current_user.recipients.find_by(id: target_id)
    end
  end

  def connect_recipient_and_create_list(recipient)
    unless recipient
      return
    end
    unless @event.recipients.exists?(recipient.id)
      @event.recipients << recipient
    end

    # create the gift list
    recipient.gift_lists.create!(
      name: "#{@event.name} - Gift list",
      event: @event
    )
  end

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :event_date, :event_time, :location, :budget, :extra_info)
  end
end
