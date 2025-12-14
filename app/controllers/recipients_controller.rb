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
    if @recipient.update(recipient_params)
      flash[:notice] = "#{@recipient.name} was successfully updated."
      redirect_to recipient_path(@recipient)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @recipient = current_user.recipients.find(params[:id])
    ai_output = AiGiftService.new(@recipient)
    # if the AI has cached suggestions, then show them automatically
    @suggestions_exist = ai_output.has_cached_suggestions?
    if @suggestions_exist
      @suggestions = ai_output.suggest_gift
    end
    @recipient_gift_lists = @recipient.gifts.group_by(&:status)

    # gift list has event id
    used_event_ids = event_ids_for_recipient(@recipient)

    @available_events = current_user.events.where.not(id: used_event_ids)


  end

  def event_ids_for_recipient(recipient)
    EventRecipient
      .where(source_recipient_id: recipient.id)
      .pluck(:event_id)
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
    @recipient_gift_lists = @recipient.gifts.group_by(&:status)
    render :show
  end


  def create_birthday_event
    @recipient = current_user.recipients.find(params[:id])

    if @recipient.has_birthday_event?
      flash[:alert] = "A birthday event already exists for #{@recipient.name}."
      redirect_to recipient_path(@recipient)
      return
    end

    if @recipient.birthday.blank?
      flash[:alert] = "Cannot create birthday event: #{@recipient.name} doesn't have an associated birthday."
      redirect_to recipient_path(@recipient)
      return
    end

    if request.post?
      budget = params[:budget].to_f if params[:budget].present?

      # Calculate the next birthday date
      birthday_this_year = @recipient.birthday.change(year: Date.current.year)
      if birthday_this_year >= Date.current
        next_birthday = birthday_this_year
      else
        next_birthday = @recipient.birthday.change(year: Date.current.year + 1)
      end

      event = current_user.events.new(
        name: "Birthday - #{@recipient.name}",
        event_date: next_birthday,
        budget: budget,
        extra_info: "Birthday celebration for #{@recipient.name}"
      )

      if event.save
        # Associate recipient with the event
        event.recipients << @recipient
        flash[:notice] = "Birthday event for #{@recipient.name} created successfully!"
        redirect_to event_path(event)
      else
        flash[:alert] = "Could not create birthday event: #{event.errors.full_messages.join(', ')}"
        render :create_birthday_event
      end
    else
      render :create_birthday_event
    end
  end

  def add_event
    @recipient = current_user.recipients.find(params[:id])
    @event = current_user.events.find(params[:event_id])
    EventRecipient.create!(
      event: @event,
      snapshot: @recipient.snapshot_attributes,
      source_recipient_id: @recipient.id
    )


    # create gift list for that event
    @recipient.gift_lists.create!(
      name: "#{@event.name} - Gift list",
      event: @event
    )
    redirect_to recipient_path(@recipient), notice: "Added #{@recipient.name} to #{@event.name}"

  rescue ActiveRecord::RecordInvalid
    redirect_to recipient_path(@recipient), alert: "Could not add recipient to event"
  end

  def destroy
    @recipient = current_user.recipients.find(params[:id])
    @recipient.destroy
    flash[:notice] = "Recipient '#{@recipient.name}' deleted."
    redirect_to recipients_path
  end

  private

  def recipient_params
    params.require(:recipient).permit(:name, :age, :age_range, :min_age, :max_age, :birthday, :gender, :relation, :occupation, :hobbies, :extra_info, likes: [], dislikes: [])
  end
end
