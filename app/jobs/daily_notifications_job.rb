class DailyNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    target_date = Date.current + 14

    send_event_reminders(target_date)
    send_birthday_reminders(target_date)
  end

  private

  def send_event_reminders(target_date)
    Event.includes(:user).where(event_date: target_date).find_each do |event|
      NotificationMailer.event_reminder(event.user, event).deliver_later
    end
  end

  # “next birthday occurrence == target_date”
  def send_birthday_reminders(target_date)
    Recipient.includes(:user).where.not(birthday: nil).find_each do |recipient|
      next_bday = next_birthday_date(recipient.birthday, Date.current)
      next unless next_bday == target_date

      NotificationMailer.birthday_reminder(recipient.user, recipient, next_bday).deliver_later
    end
  end

  def next_birthday_date(birthday, today)
    candidate = Date.new(today.year, birthday.month, birthday.day)
    candidate += 1.year if candidate < today
    candidate
  rescue Date::Error
    # handles Feb 29 on non-leap years; choose Feb 28 (or Mar 1 if you prefer)
    Date.new(today.year, 2, 28).tap { |d| d += 1.year if d < today }
  end
end
