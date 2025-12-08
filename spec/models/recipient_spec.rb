require 'rails_helper'

RSpec.describe Recipient, type: :model do
  let(:user) do
    User.create!(
      name: "Chad",
      email: "chad_bro_chill@fakemail.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  def build_recipient(attrs = {})
    Recipient.new(
      {
        user: user,
        name: "Billy Bob",
        gender: 0,
        min_age: 20,
        max_age: 20,
        relation: "Brother",
        likes: %w[Reading],
        dislikes: %w[Math]
      }.merge(attrs)
    )
  end

  describe "validations" do
    it "is valid with required attributes" do
      recipient = build_recipient
      expect(recipient).to be_valid
    end

    it "requires a name" do
      recipient = build_recipient(name: "")
      expect(recipient).not_to be_valid
    end

    it "requires a gender" do
      recipient = build_recipient(gender: nil)
      expect(recipient).not_to be_valid
    end

    it "requires either birthday, age, or min_age" do
      recipient = build_recipient(age: nil, birthday: nil, min_age: nil, max_age: nil)
      expect(recipient).not_to be_valid
    end

    it "accepts min age when birthday is unknown" do
      recipient = build_recipient(age: nil, birthday: nil, min_age: 20)
      expect(recipient).to be_valid
    end

    it "does not allow negative ages" do
      recipient = build_recipient(age: -1)
      expect(recipient).not_to be_valid
    end

    it "does not allow ages >= 120" do
      recipient = build_recipient(age: 121)
      expect(recipient).not_to be_valid
    end

    it "validates min and max age" do
      recipient = build_recipient(age: nil, birthday: nil, min_age: 30, max_age: 20)
      expect(recipient).not_to be_valid
    end

    it "requires min age if max is present" do
      recipient = build_recipient(age: nil, birthday: nil, min_age: nil, max_age: 40)
      expect(recipient).not_to be_valid
    end
  end

  describe "likes and dislikes serialization" do
    it "stores likes and dislikes as arrays" do
      recipient = build_recipient(
        likes: [ "Reading", "Yoga" ],
        dislikes: [ "Math" ]
      )
      recipient.save!

      recipient.reload
      expect(recipient.likes).to eq([ "Reading", "Yoga" ])
      expect(recipient.dislikes).to eq([ "Math" ])
    end

    it "handles nil likes/dislikes" do
      recipient = build_recipient(likes: nil, dislikes: nil)
      recipient.save!

      recipient.reload
      expect(recipient.likes).to be_nil
      expect(recipient.dislikes).to be_nil
    end
  end

  describe "calculate age feature" do
    let(:today) { Date.new(2025, 12, 6) }

    before do
      allow(Date).to receive(:current).and_return(today)
    end

    it "sets age based on date" do
      birthday = Date.new(2000, 1, 1)
      recipient = build_recipient(age: nil, birthday: birthday)
      recipient.save!
      recipient.reload
      expect(recipient.age). to eq(25)
    end

    it "clears age if min age set" do
      birthday = Date.new(2000, 1, 1)
      recipient = build_recipient(age: nil, birthday: birthday)
      recipient.save!

      recipient.update!(birthday: nil, min_age: 20, max_age: 30)

      recipient.reload
      expect(recipient.age).to be_nil
    end
  end
  describe "associations" do
    it "can be associated with events through event_recipients" do
      event = user.events.create!(
        name: "Beer oclock",
        event_date: Date.today + 4
      )
      recipient = build_recipient
      recipient.save!

      event.recipients << recipient

      expect(event.recipients).to include(recipient)
      expect(recipient.events).to include(event)
    end
  end
end
