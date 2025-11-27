class HomeController < ApplicationController
  def show
    @recipients = current_user.recipients.order(:name)
    @events = current_user.events.order(:event_date, :event_time)
  end
end
