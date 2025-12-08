require 'rails_helper'

RSpec.describe GiftOffer, type: :model do
  let(:user) do
    User.create!(
      name:                  "Test User",
      email:                 "test@example.com",
      password:              "password123",
      password_confirmation: "password123"
    )
  end

  let(:recipient) do
    user.recipients.create!(
      name:     "Thad",
      min_age:      30,
      gender:   0,
      relation: "Friend",
      likes:    [],
      dislikes: []
    )
  end

  let(:gift_list) do
    recipient.gift_lists.create!(name: "Birthday Wishlist")
  end

  let(:gift) do
    gift_list.gifts.create!(name: "Nike socks")
  end

  describe "associations" do
    it "belongs to a gift" do
      offer = GiftOffer.new(
        gift:       gift,
        store_name: "Target",
        price:      12.99,
        currency:   "USD"
      )
      expect(offer.gift).to eq(gift)
    end
  end

  describe "validations" do
    it "is valid with a gift, store_name, price, and currency" do
      offer = GiftOffer.new(
        gift:       gift,
        store_name: "Target",
        price:      12.99,
        currency:   "USD"
      )
      expect(offer).to be_valid
    end

    it "is invalid without a store_name" do
      offer = GiftOffer.new(
        gift:     gift,
        price:    12.99,
        currency: "USD"
      )
      expect(offer).not_to be_valid
      expect(offer.errors[:store_name]).to be_present
    end

    it "is invalid without a price" do
      offer = GiftOffer.new(
        gift:       gift,
        store_name: "Target",
        currency:   "USD"
      )
      expect(offer).not_to be_valid
      expect(offer.errors[:price]).to be_present
    end

    it "is invalid with a negative price" do
      offer = GiftOffer.new(
        gift:       gift,
        store_name: "Target",
        price:      -1,
        currency:   "USD"
      )
      expect(offer).not_to be_valid
      expect(offer.errors[:price]).to be_present
    end

    it "allows a nil rating" do
      offer = GiftOffer.new(
        gift:       gift,
        store_name: "Target",
        price:      12.99,
        currency:   "USD",
        rating:     nil
      )
      expect(offer).to be_valid
    end

    it "is invalid with a rating > 5" do
      offer = GiftOffer.new(
        gift:       gift,
        store_name: "Target",
        price:      12.99,
        currency:   "USD",
        rating:     6.0
      )
      expect(offer).not_to be_valid
      expect(offer.errors[:rating]).to be_present
    end

    it "is invalid without a url" do
      offer = GiftOffer.new(
        gift:       gift,
        store_name: "Target",
        price:      12.99,
        currency:   "USD",
        url:        nil
      )
      expect(offer).not_to be_valid
      expect(offer.errors[:url]).to be_present
    end

    it "is invalid with a non-http(s) url" do
      offer = GiftOffer.new(
        gift:       gift,
        store_name: "Target",
        price:      12.99,
        currency:   "USD",
        url:        "javascript:alert('xss')"
      )
      expect(offer).not_to be_valid
      expect(offer.errors[:url]).to be_present
    end
  end
end
