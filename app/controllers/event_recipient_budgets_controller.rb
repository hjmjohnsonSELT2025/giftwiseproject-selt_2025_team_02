class EventRecipientBudgetsController < ApplicationController
    before_action :set_event_recipient_budget, only: %i[show edit update destroy]
    before_action :load_events_and_recipients, only: %i[new create edit update]

    def index
      @events = Event.where(user_id: current_user.id).order(:event_date)

      if params[:event_id].present?
        @selected_event = @events.find_by(id: params[:event_id])

        if @selected_event
          @event_recipients = @selected_event.event_recipients
          @budgets_by_event_recipient =
            EventRecipientBudget
              .joins(:event_recipient)
              .where(event_recipients: { event_id: @selected_event.id })
              .index_by(&:event_recipient_id)

          @event_total_budget     = @selected_event.budget || 0
          @event_planned_budget   = @budgets_by_event_recipient.values.sum(&:budget)
          @event_spent_budget     = @budgets_by_event_recipient.values.sum(&:spent)
          @event_remaining_budget = @event_total_budget - @event_planned_budget
        else
          reset_budget_state
        end
      else
        reset_budget_state
      end
    end
    def reset_budget_state
      @selected_event = nil
      @event_recipients = []
      @budgets_by_event_recipient = {}
      @event_total_budget =
        @event_planned_budget =
          @event_spent_budget =
            @event_remaining_budget = 0
    end

    def show
    end

    def new
        @event_recipient_budget = EventRecipientBudget.new(
          event_id: params[:event_id],
          event_recipient_id: params[:event_recipient_id]
        )
    end

    def create
      event, event_recipient = find_event_and_recipient_from_params

      @event_recipient_budget =
        EventRecipientBudget.new(event_recipient_budget_params)

      @event_recipient_budget.event_recipient = event_recipient

      if @event_recipient_budget.save
        redirect_to event_path(event),
                    notice: "Budget successfully created!"
      else
        flash[:warning] = "There was a problem creating the budget."
        render :new, status: :unprocessable_entity
      end
    end


    def edit
        if @event_recipient_budget.event
            @event_recipient_budget.event_id = @event_recipient_budget.event.id
        end
        if @event_recipient_budget.event_recipient
            @event_recipient_budget.event_recipient_id = @event_recipient_budget.event_recipient.id
        end
    end

    def update
      if @event_recipient_budget.update(event_recipient_budget_params)
        redirect_to(
          event_path(@event_recipient_budget.event_recipient.event),
          notice: "Budget successfully updated!"
        )
      else
        flash.now[:warning] = "There was a problem updating the budget."
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
        event = @event_recipient_budget.event
        @event_recipient_budget.destroy
        redirect_to event_recipient_budgets_path(event_id: event&.id), notice: "Budget successfully deleted."
    end

    private

    def set_event_recipient_budget
        @event_recipient_budget = EventRecipientBudget.find(params[:id])

        if @event_recipient_budget.event.user_id != current_user.id
            redirect_to event_recipient_budgets_path, alert: "Budget not found."
        end
        rescue ActiveRecord::RecordNotFound
            redirect_to event_recipient_budgets_path, alert: "Budget not found."
    end


    def load_events_and_recipients
        @events = Event.where(user_id: current_user.id).order(:event_date)
        @recipients = current_user.recipients
    end

    def event_recipient_budget_params
        params.require(:event_recipient_budget).permit(:budget, :spent)
    end

    def find_event_and_recipient_from_params
      event_id =
        params[:event_id] ||
        params.dig(:event_recipient_budget, :event_id)

      event_recipient_id =
        params[:event_recipient_id] ||
        params.dig(:event_recipient_budget, :event_recipient_id)

      raise "event_id missing" if event_id.blank?
      raise "event_recipient_id missing" if event_recipient_id.blank?

      event = Event.find(event_id)
      event_recipient = event.event_recipients.find(event_recipient_id)

      [event, event_recipient]
    end



end
