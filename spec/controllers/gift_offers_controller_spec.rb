require 'rails_helper'

RSpec.describe "GiftOffers", type: :request do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password", password_confirmation: "password") }

  let!(:recipient) do
    Recipient.create!(
      name: "Test Recipient",
      user_id: user.id,
      gender: :male,
      relation: "Friend",
      age: 25
    )
  end

  let!(:gift_list) { GiftList.create!(name: "Christmas List", recipient_id: recipient.id) }

  let!(:gift) do
    Gift.create!(
      name: "Smart Watch",
      status: :idea,
      gift_list_id: gift_list.id
    )
  end

  let(:valid_attributes) do
    {
      store_name: "Best Buy",
      price: 299.99,
      currency: "USD",
      url: "https://www.bestbuy.com/smartwatch",
      rating: 4.5
    }
  end

  let(:invalid_attributes) do
    {
      store_name: "",
      price: nil
    }
  end
  let(:headers) { { "Accept" => "text/html" } }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /new" do
    it "returns http success" do
      get new_recipient_gift_list_gift_gift_offer_path(recipient, gift_list, gift), headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new GiftOffer" do
        expect {
          post recipient_gift_list_gift_gift_offers_path(recipient, gift_list, gift),
               params: { gift_offer: valid_attributes },
               headers: headers
        }.to change(GiftOffer, :count).by(1)
      end

      it "redirects to the gift show page" do
        post recipient_gift_list_gift_gift_offers_path(recipient, gift_list, gift),
             params: { gift_offer: valid_attributes },
             headers: headers
        expect(response).to redirect_to(recipient_gift_list_gift_path(recipient, gift_list, gift))
        follow_redirect!
        expect(response.body).to include("Purchase option was successfully added")
      end
    end

    context "with invalid parameters" do
      it "does not create a new GiftOffer" do
        expect {
          post recipient_gift_list_gift_gift_offers_path(recipient, gift_list, gift),
               params: { gift_offer: invalid_attributes },
               headers: headers
        }.to change(GiftOffer, :count).by(0)
      end

      it "renders a response with 422 status" do
        post recipient_gift_list_gift_gift_offers_path(recipient, gift_list, gift),
             params: { gift_offer: invalid_attributes },
             headers: headers
        expect([422, 204, 406]).to include(response.status)
      end
    end
  end

  describe "Security" do
    it "redirects when accessing another user's data" do
      other_user = User.create!(name: "Other", email: "other@example.com", password: "password", password_confirmation: "password")
      other_recipient = Recipient.create!(name: "Other Rec", user_id: other_user.id, gender: :male, relation: "Friend", age: 30)
      other_list = GiftList.create!(name: "Other List", recipient_id: other_recipient.id)
      other_gift = Gift.create!(name: "Other Gift", status: :idea, gift_list_id: other_list.id)
      get new_recipient_gift_list_gift_gift_offer_path(other_recipient, other_list, other_gift), headers: headers
      expect(response).to have_http_status(:found)
    end
  end
end