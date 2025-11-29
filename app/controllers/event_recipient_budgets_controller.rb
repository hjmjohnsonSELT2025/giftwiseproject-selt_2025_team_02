class EventRecipientBudgetsController < ApplicationController
    before_action :set_event_recipient_budget, only: %i[show edit update destroy]
    before_action :load_events_and_recipients, only: %i[new create edit update]

    def index
        @events = Event.where(user_id: current_user.id).order(:event_date)
        if params[:event_id].present?
            @selected_event = @events.find_by(id: params[:event_id])
            if @selected_event
                @recipients = current_user.recipients
                @budgets_by_recipient = EventRecipientBudget
                    .joins(:event_recipient)
                    .where(event_recipients: { event_id: @selected_event.id })
                    .includes(:recipient)
                    .index_by { |b| b.recipient.id }

                @event_total_budget = @selected_event.budget || 0
                @event_planned_budget = @budgets_by_recipient.values.sum(&:budget)
                @event_spent_budget = @budgets_by_recipient.values.sum(&:spent)
                @event_remaining_budget = @event_total_budget - @event_planned_budget
            else
                @recipients = []
                @budgets_by_recipient = {}
                @event_total_budget = @event_planned_budget = @event_spent_budget = @event_remaining_budget = 0
            end
        else
        @selected_event = nil
        @recipients = []
        @budgets_by_recipient = {}
        @event_total_budget = @event_planned_budget = @event_spent_budget = @event_remaining_budget = 0
        end
    end

    def show
    end

    def new
        @event_recipient_budget = EventRecipientBudget.new
        if params[:event_id].present?
            @event_recipient_budget.event_id = params[:event_id].to_i
        end
        if params[:recipient_id].present?
            @event_recipient_budget.recipient_id = params[:recipient_id].to_i
        end
    end

    def create
        event, recipient = find_event_and_recipient_from_params
        if event.nil? || recipient.nil?
            @event_recipient_budget = EventRecipientBudget.new(event_recipient_budget_params)
            flash[:warning] = "You must select a valid event & recipient"
            load_events_and_recipients
            return render :new, status: :unprocessable_entity
        end

        event_recipient = EventRecipient.find_or_create_by!(event: event, recipient: recipient)
        @event_recipient_budget = EventRecipientBudget.new(event_recipient_budget_params)
        @event_recipient_budget.event_recipient = event_recipient

        if @event_recipient_budget.save
            redirect_to event_recipient_budgets_path(event_id: event.id), notice: "Budget successfully created!"
        else
            flash[:warning] = "There was a problem creating the budget."
            load_events_and_recipients
            render :new, status: :unprocessable_entity
        end
    end

    def edit
        if @event_recipient_budget.event
            @event_recipient_budget.event_id = @event_recipient_budget.event.id
        end
        if @event_recipient_budget.recipient
            @event_recipient_budget.recipient_id = @event_recipient_budget.recipient.id
        end
    end

    def update
        event, recipient = find_event_and_recipient_from_params
        if event && recipient
            event_recipient = EventRecipient.find_or_create_by!(event: event, recipient: recipient)
            @event_recipient_budget.event_recipient = event_recipient
        end
        if @event_recipient_budget.update(event_recipient_budget_params)
            redirect_to event_recipient_budget_path(event_id: @event_recipient_budget.event.id), notice: "Budget successfully updated!"
        else
            flash[:warning] = "There was a problem updating the budget."
            load_events_and_recipients
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
        er_params = params[:event_recipient_budget] || {}
        event_id = er_params[:event_id]
        recipient_id = er_params[:recipient_id]

        event = Event.where(user_id: current_user.id).find_by(id: event_id)
        recipient = current_user.recipients.find_by(id: recipient_id)

        [ event, recipient ]
  end
end
