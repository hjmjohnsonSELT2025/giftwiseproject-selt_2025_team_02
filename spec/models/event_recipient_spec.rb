require "rails_helper"

RSpec.describe EventRecipient, type: :model do
  def create_user(email: "user@example.com")
    User.create!(
      name: "Test User",
      email: email,
      password: "password",
      password_confirmation: "password"
    )
  end

  def create_event(user:)
    Event.create!(
      user: user,
      name: "Test Event",
      event_date: Date.today + 1
    )
  end

  def create_recipient(user:)
    Recipient.create!(
      user: user,
      name: "Test Recipient",
      birthday: Date.new(2000, 1, 1),
      gender: :male,
      relation: "Friend",
      likes: ["Books"],
      dislikes: ["Loud noises"]
    )
  end

  describe "validations and invariants" do
    it "is valid with an event, source_recipient_id, and snapshot" do
      user = create_user
      recipient = create_recipient(user: user)
      event = create_event(user: user)

      er = EventRecipient.new(
        event: event,
        source_recipient_id: recipient.id,
        snapshot: recipient.snapshot_attributes
      )

      expect(er).to be_valid
    end

    it "is invalid without an event" do
      er = EventRecipient.new(
        event: nil,
        snapshot: {}
      )

      expect(er).not_to be_valid
      expect(er.errors[:event]).to include("must exist")
    end

    it "does not allow the same source recipient to be added twice" do
      user = create_user
      recipient = create_recipient(user: user)
      event = create_event(user: user)

      EventRecipient.create!(
        event: event,
        source_recipient_id: recipient.id,
        snapshot: {}
      )

      duplicate = EventRecipient.new(
        event: event,
        source_recipient_id: recipient.id,
        snapshot: {}
      )

      expect(duplicate).not_to be_valid
    end

    it "stores a snapshot independent of future recipient changes" do
      user = create_user
      recipient = create_recipient(user: user)
      event = create_event(user: user)

      er = EventRecipient.create!(
        event: event,
        source_recipient_id: recipient.id,
        snapshot: recipient.snapshot_attributes
      )

      recipient.update!(name: "Changed Name")

      expect(er.snapshot["name"]).to eq("Test Recipient")
    end

    it "raises if user does not own source recipient" do
      owner = create_user(email: "owner@example.com")
      intruder = create_user(email: "intruder@example.com")

      recipient = create_recipient(user: owner)
      event = create_event(user: owner)

      er = EventRecipient.create!(
        event: event,
        source_recipient_id: recipient.id,
        snapshot: { "name" => "Injected" }
      )

      expect {
        er.sync_back!(intruder)
      }.to raise_error("Not authorized")
    end
  end

  describe "associations" do
    it "destroys associated budget when deleted" do
      user = create_user
      event = create_event(user: user)

      er = EventRecipient.create!(
        event: event,
        snapshot: {}
      )

      EventRecipientBudget.create!(
        event_recipient: er,
        budget: 100,
        spent: 0
      )

      expect {
        er.destroy
      }.to change { EventRecipientBudget.count }.by(-1)
    end
  end

  describe "#recipient_view" do
    it "returns a RecipientProxy built from snapshot" do
      er = EventRecipient.new(
        snapshot: {
          "name" => "Alex",
          "likes" => ["Books"]
        }
      )

      proxy = er.recipient_view

      expect(proxy.name).to eq("Alex")
      expect(proxy.likes).to eq(["Books"])
    end
  end

  describe "#source_gift_list" do
    it "returns nil if there is no source recipient" do
      er = EventRecipient.new(source_recipient_id: nil)

      expect(er.source_gift_list).to be_nil
    end
  end
end
