class HomeController < ApplicationController
  TABS = {
    "overview" => "home/tabs/overview",
    "events" => "home/tabs/events",
    "recipients" => "home/tabs/recipients",
    "budgets" => "home/tabs/budgets",
    "lists" => "home/tabs/lists"

  }.freeze


  def show
    @tab = TABS[params[:tab]] || TABS["overview"]
    @recipients = current_user.recipients.order(:name)
    @events = current_user.events.order(:event_date, :event_time)
    @budgets = EventRecipientBudget
      .joins(:event_recipient)
      .where(event_recipients: { event_id: current_user.events.pluck(:id) })
      .includes(:event_recipient, :event, :recipient)
      .order("events.event_date")
  end




end
