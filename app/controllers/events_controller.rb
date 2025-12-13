class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy add_recipient remove_recipient]

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
    @event.recipients << recipient unless @event.recipients.exists?(recipient.id)
    redirect_to event_path(@event),
                notice: "Recipient '#{recipient.name}' successfully added to '#{@event.name}'."
  end

  def remove_recipient
    recipient = @event.recipients.find(params[:recipient_id])
    @event.recipients.delete(recipient)
    redirect_to event_path(@event),
                notice: "Recipient '#{recipient.name}' successfully removed from '#{@event.name}'."
  end

  def add_collaborator
    @event = Event.find(params[:id])

    # Optional safety check
    unless @event.user == current_user
      flash[:warning] = "Only the event owner can add collaborators."
      return redirect_to @event
    end

    user = User.find_by(email: params[:email])

    if user.nil?
      flash[:warning] = "No user found with that email."
    elsif @event.collaborators.include?(user)
      flash[:notice] = "That user is already a collaborator."
    else
      @event.collaborators << user
      flash[:notice] = "#{user.email} added as collaborator."
    end

    redirect_to @event
  end

  private

  def set_event
    @event =
      current_user.events.find_by(id: params[:id]) ||
      current_user.collaborating_events.find_by(id: params[:id])

    raise ActiveRecord::RecordNotFound unless @event
  end

  def event_params
    params.require(:event).permit(:name, :event_date, :event_time, :location, :budget, :extra_info)
  end
end
