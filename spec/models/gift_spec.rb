require 'rails_helper'

RSpec.describe Gift, type: :model do


  let(:gift_list_double) { instance_double(GiftList) }

  describe 'validations and associations' do
    it 'is valid with a name and a gift_list' do
      gift = Gift.new(name: "Batman", gift_list: gift_list_double)
      expect(gift.valid?).to eq(true)
    end

    it 'is invalid without a name' do
      gift = Gift.new(name: nil, gift_list: gift_list_double)
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
