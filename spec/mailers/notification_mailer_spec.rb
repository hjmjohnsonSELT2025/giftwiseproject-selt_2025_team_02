require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "event_reminder" do
    let(:mail) { NotificationMailer.event_reminder }

    it "renders the headers" do
      expect(mail.subject).to eq("Event reminder")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "birthday_reminder" do
    let(:mail) { NotificationMailer.birthday_reminder }

    it "renders the headers" do
      expect(mail.subject).to eq("Birthday reminder")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
