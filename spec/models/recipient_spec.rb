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
        birthday: Date.new(2000, 1, 1),
        relation: "Brother",
        occupation: "Software Engineer",
        hobbies: "Coding, Technology, Reading",
        extra_info: "Allergic to peanuts",
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
      recipient = build_recipient(birthday: nil, min_age: 25, max_age: 34)
      expect(recipient).to be_valid
    end

    it "does not allow negative ages" do
      recipient = build_recipient(birthday: Date.new(2026, 1, 1))
      expect(recipient).not_to be_valid
    end

    it "does not allow ages >= 120" do
      recipient = build_recipient(birthday: Date.new(1800, 1, 1))
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
      expect(recipient.age).to eq(25)
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
      recipient = Recipient.create!(
        user: user,
        name: "Drinking Buddy",
        gender: :male,
        relation: "Friend",
        age: 25
      )
      EventRecipient.create!(
        event: event,
        source_recipient_id: recipient.id,
        snapshot: recipient.snapshot_attributes
      )
      join_record = EventRecipient.find_by(event: event, source_recipient_id: recipient.id)

      expect(join_record).to be_present
      expect(join_record.snapshot["name"]).to eq("Drinking Buddy")
    end
  end

  describe "additional detail fields" do
    it "allows occupation, hobbies, and extra_info to be set and persisted" do
      recipient = build_recipient(
        occupation: "Nurse",
        hobbies: "Running\nPainting\nBoard games",
        extra_info: "Prefers experiences over physical gifts"
      )

      expect(recipient).to be_valid
      recipient.save!
      recipient.reload

      expect(recipient.occupation).to eq("Nurse")
      expect(recipient.hobbies).to include("Painting")
      expect(recipient.extra_info).to eq("Prefers experiences over physical gifts")
    end

    it "treats occupation, hobbies, and extra_info as optional" do
      recipient = build_recipient(
        occupation: nil,
        hobbies: nil,
        extra_info: nil
      )

      expect(recipient).to be_valid
    end
  end
end
