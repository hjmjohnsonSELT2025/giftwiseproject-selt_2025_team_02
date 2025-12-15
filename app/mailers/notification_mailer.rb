class NotificationMailer < ApplicationMailer
  def event_reminder(user, event)
    @user = user
    @event = event
    mail(to: @user.email, subject: "Reminder: #{@event.name} is coming up within 14 days")
  end

  def birthday_reminder(user, recipient, birthday_date)
    @user = user
    @recipient = recipient
    @birthday_date = birthday_date
    mail(to: @user.email, subject: "Reminder: #{@recipient.name}'s birthday is coming up within 14 days")
  end
end

