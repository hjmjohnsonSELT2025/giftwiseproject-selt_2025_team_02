require 'rails_helper'

RSpec.describe Gift, type: :model do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password", password_confirmation: "password") }

  let(:recipient) do
    Recipient.create!(
      name: "Test Recipient",
      user_id: user.id,
      gender: :male,
      relation: "Friend",
      age: 25
    )
  end

  let(:real_gift_list) { GiftList.create!(name: "Birthday List", recipient: recipient) }

  describe 'validations and associations' do
    it 'is valid with a name and a gift_list' do
      gift = Gift.new(name: "Batman", gift_list: real_gift_list)
      expect(gift).to be_valid
    end

    it 'is invalid without a name' do
      gift = Gift.new(name: nil, gift_list: real_gift_list)
      expect(gift).not_to be_valid
      expect(gift.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a gift_list' do
      gift = Gift.new(name: "Book", gift_list: nil)
      expect(gift).not_to be_valid
      expect(gift.errors[:gift_list]).to include("must exist")
    end
  end
end
