require 'rails_helper'

RSpec.describe GiftList, type: :model do
  let(:recipient_double) { instance_double(User) }
  describe 'validations and associations' do
    it 'is valid with a name and a recipient' do
      gift_list = GiftList.new(name: "Birthday List", recipient: recipient_double)
      expect(gift_list.valid?).to eq(true)
    end

    it 'is invalid without a name' do
      gift_list = GiftList.new(name: nil, recipient: recipient_double)
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
