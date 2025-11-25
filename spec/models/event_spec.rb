require "rails_helper"

RSpec.describe Event, type: :model do
  let(:user) do
    User.create!(
      name: "Chad",
      email: "chad_bro_chill@fakemail.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  describe "validations and associations" do
    it "is valid with a name, event_date, and user" do
      event = Event.new(
        name: "Beer oclock",
        event_date: Date.today + 4,
        user: user
      )

      expect(event.valid?).to eq(true)
    end

    it "is invalid without a name" do
      event = Event.new(
        name: nil,
        event_date: Date.today + 4,
        user: user
      )

      expect(event).not_to be_valid
      expect(event.errors[:name]).to include("can't be blank")
    end

    it "is invalid without an event_date" do
      event = Event.new(
        name: "Beer oclock",
        event_date: nil,
        user: user
      )

      expect(event).not_to be_valid
      expect(event.errors[:event_date]).to include("can't be blank")
    end

    it "is invalid without a user" do
      event = Event.new(
        name: "Beer oclock",
        event_date: Date.today + 4,
        user: nil
      )

      expect(event).not_to be_valid
      expect(event.errors[:user]).to include("must exist")
    end
  end
end
