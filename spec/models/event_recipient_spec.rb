require "rails_helper"

RSpec.describe EventRecipient, type: :model do
  let(:user) do
    User.create!(
      name: "Chad",
      email: "chad_bro_chill@fakemail.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  let(:recipient) do
    Recipient.create!(
      user: user,
      name: "Thaddeus Capcap",
      birthday: Date.new(2000, 1, 1),
      gender: :male,
      relation: "Bro",
      likes: %w[Yoga Meditation],
      dislikes: %w[Math]
    )
  end

  let(:event) do
    Event.create!(
      user: user,
      name: "Beer oclock",
      event_date: Date.today + 4
    )
  end

  describe "validations and associations" do
    it "is valid with an event and a recipient" do
      event_recipient = EventRecipient.new(event: event, recipient: recipient)

      expect(event_recipient.valid?).to eq(true)
    end

    it "is invalid without an event" do
      event_recipient = EventRecipient.new(event: nil, recipient: recipient)

      expect(event_recipient).not_to be_valid
      expect(event_recipient.errors[:event]).to include("must exist")
    end

    it "is invalid without a recipient" do
      event_recipient = EventRecipient.new(event: event, recipient: nil)

      expect(event_recipient).not_to be_valid
      expect(event_recipient.errors[:recipient]).to include("must exist")
    end

    it "does not allow the same recipient to be added to the same event twice" do
      EventRecipient.create!(event: event, recipient: recipient)
      duplicate = EventRecipient.new(event: event, recipient: recipient)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:event_id]).to include("has already been taken")
    end
  end
end
