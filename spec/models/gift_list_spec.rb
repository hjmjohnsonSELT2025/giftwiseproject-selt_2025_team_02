require 'rails_helper'

RSpec.describe GiftList, type: :model do
  let(:user) do
    User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  let(:recipient) do
    Recipient.create!(
      name: "Test Recipient",
      user_id: user.id,
      gender: :male,
      relation: "Friend",
      age: 25
    )
  end

  describe 'validations and associations' do
    it 'is valid with a name and a recipient' do
      gift_list = GiftList.new(name: "Birthday List", recipient: recipient)
      expect(gift_list).to be_valid
    end

    it 'is invalid without a name' do
      gift_list = GiftList.new(name: nil, recipient: recipient)
      expect(gift_list).not_to be_valid
      expect(gift_list.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a recipient' do
      gift_list = GiftList.new(name: "Birthday List", recipient: nil)
      expect(gift_list).not_to be_valid
      expect(gift_list.errors[:recipient]).to include("must exist")
    end
  end
end