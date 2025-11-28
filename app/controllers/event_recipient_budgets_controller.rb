class EventRecipientBudgetsController < ApplicationController
    before_action :set_event_recipient_budget, only: %i[show edit update destroy]
    before_action :load_events_and_recipients, only: %i[new create edit update]

    def index
        @event_recipient_budgets = current_user.event_recipient_budgets
        @events = current_user.events
        if params[:event_id].present?
            @selected_event = @events.find_by(id: params[:event_id])
            if @selected_event
                @recipients = current_user.recipients
                @budgets_by_recipient = EventRecipientBudget.where(event: @selected_event).index_by(&:recipient_id)
            else
                @recipients = []
                @budgets_by_recipient = {}
            end
        else
        @selected_event = nil
        @recipients = []
        @budgets_by_recipient = {}
        end
    end

    def show
        @event_recipient_budget = current_user.event_recipient_budget
    end

    def new
        @event_recipient_budget = EventRecipientBudget.new
    end

    def create
        @event_recipient_budget = current_user.event_recipient_budgets.new(event_recipient_budget_params)
        if @event_recipient_budget.save
            redirect_to event_recipient_budgets_path, notice: "Budget successfully created!"
        else
            flash.now[:warning] = "There was a problem creating the budget."
            load_events_and_recipients
            render :new, status: :unprocessable_entity
        end
    end

    def edit
    end

    def update
        if @event_recipient_budget.update(event_recipient_budget_params)
            redirect_to event_recipient_budget_path(@event_recipient_budget), notice: "Budget successfully updated!"
        else
            flash[:warning] = "There was a problem updating the budget."
            load_events_and_recipients
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @event_recipient_budget.destroy
        redirect_to event_recipient_budgets_path, notice: "Budget successfully deleted."
    end

    private

    def set_event_recipient_budget
        @event_recipient_budget = current_user.event_recipient_budgets.find(params[:id])
        rescue ActiveRecord::RecordNotFound
            redirect_to event_recipient_budgets_path, alert: "Budget not found."
    end


    def load_events_and_recipients
        @events = current_user.events
        @recipients = current_user.recipients
    end

    def event_recipient_budget_params
        params.require(:event_recipient_budget).permit(:event_id, :recipient_id, :total_budget, :spent_budget)
    end
end