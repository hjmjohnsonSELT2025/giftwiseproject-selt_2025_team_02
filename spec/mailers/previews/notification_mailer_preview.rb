# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer_mailer
class NotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer_mailer/event_reminder
  def event_reminder
    NotificationMailer.event_reminder
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer_mailer/birthday_reminder
  def birthday_reminder
    NotificationMailer.birthday_reminder
  end

end
