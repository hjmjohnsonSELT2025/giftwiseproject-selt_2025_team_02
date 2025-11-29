class HomeController < ApplicationController
  def show
    @tab = params[:tab] || "overview"
    @recipients = current_user.recipients.order(:name)
    @events = current_user.events.order(:event_date, :event_time)
    @budgets = EventRecipientBudget
      .joins(:event_recipient)
      .where(event_recipients: { event_id: current_user.events.pluck(:id) })
      .includes(:event_recipient, :event, :recipient)
      .order("events.event_date")
  end
end
