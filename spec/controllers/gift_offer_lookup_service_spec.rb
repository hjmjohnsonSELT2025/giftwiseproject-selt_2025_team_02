require 'rails_helper'

RSpec.describe GiftOfferLookupService do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password", password_confirmation: "password") }
  let(:recipient) { Recipient.create!(name: "Test Recipient", user_id: user.id, gender: :male, relation: "Friend", age: 25) }
  let(:gift_list) { GiftList.create!(name: "Christmas List", recipient_id: recipient.id) }
  let(:gift) { Gift.create!(name: "nike socks", status: :idea, gift_list_id: gift_list.id) }

  subject { described_class.new(gift) }

  describe "#ensure_offers!" do
    context "when in test environment (using static catalog)" do
      it "creates offers based on the static catalog" do
        expect {
          subject.ensure_offers!
        }.to change(GiftOffer, :count).by(1)

        offer = gift.gift_offers.last
        expect(offer.store_name).to eq("Amazon")
        expect(offer.price).to eq(11.99)
      end

      it "does not create new offers if they already exist and force is false" do
        subject.ensure_offers!
        expect {
          subject.ensure_offers!(force: false)
        }.not_to change(GiftOffer, :count)
      end

      it "deletes and recreates offers if force is true" do
        subject.ensure_offers!
        original_id = gift.gift_offers.first.id
        subject.ensure_offers!(force: true)

        expect(gift.gift_offers.count).to eq(1)
        expect(gift.gift_offers.first.id).not_to eq(original_id)
      end

      it "does nothing if the gift name is not in the static catalog" do
        gift.update!(name: "Non-existent Item")
        expect {
          subject.ensure_offers!
        }.not_to change(GiftOffer, :count)
      end
    end
    context "when API integration is active" do
      let(:fake_api_body) do
        {
          "shopping_results" => [
            {
              "source" => "Walmart",
              "extracted_price" => 10.0,
              "product_link" => "https://walmart.com/item",
              "rating" => 4.5
            },
            {
              "source" => "Walmart",
              "extracted_price" => 15.0,
              "product_link" => "https://walmart.com/expensive",
              "rating" => 4.0
            },
            {
              "source" => "Target",
              "price" => "$20.00",
              "product_link" => "https://target.com/item",
              "rating" => 5.0
            }
          ]
        }.to_json
      end

      before do
        allow(Rails.env).to receive(:test?).and_return(false)
        allow(ENV).to receive(:[]).with("SERPAPI_API_KEY").and_return("fake_key")

        response_double = instance_double(HTTP::Response,
                                          status: instance_double(HTTP::Response::Status, success?: true),
                                          body: fake_api_body)
        allow(HTTP).to receive(:get).and_return(response_double)
      end

      it "fetches from API, deduplicates stores, and sorts by price" do
        subject.ensure_offers!(force: true)

        offers = gift.gift_offers.order(:price)

        expect(offers.count).to eq(2)

        cheapest = offers.first
        expect(cheapest.store_name).to eq("Walmart")
        expect(cheapest.price).to eq(10.0)

        expensive = offers.last
        expect(expensive.store_name).to eq("Target")
        expect(expensive.price).to eq(20.0)
      end

      it "handles API failures gracefully by returning empty" do
        fail_response = instance_double(HTTP::Response, status: instance_double(HTTP::Response::Status, success?: false))
        allow(HTTP).to receive(:get).and_return(fail_response)
        gift.update!(name: "Rare Item")

        expect {
          subject.ensure_offers!
        }.not_to change(GiftOffer, :count)
      end
    end
  end
end
