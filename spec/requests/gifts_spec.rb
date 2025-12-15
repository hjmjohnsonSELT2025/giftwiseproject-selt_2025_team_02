require 'rails_helper'

RSpec.describe "Gifts", type: :request do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password", password_confirmation: "password") }
  let!(:recipient) { Recipient.create!(name: "Test Recipient", user_id: user.id, gender: :male, relation: "Friend", age: 25) }
  let!(:gift_list) { GiftList.create!(name: "Christmas List", recipient_id: recipient.id) }

  let(:valid_attributes) { { name: "Lego Set", status: :idea } }
  let(:invalid_attributes) { { name: "" } }
  let(:headers) { { "Accept" => "text/html" } }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /new" do
    it "returns http success" do
      get new_gift_list_gift_path(gift_list), headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Gift" do
        expect {
          post gift_list_gifts_path(gift_list), params: { gift: valid_attributes }, headers: headers
        }.to change(Gift, :count).by(1)
      end

      it "redirects to the recipient page" do
        post gift_list_gifts_path(gift_list), params: { gift: valid_attributes }, headers: headers
        expect(response).to redirect_to(recipient_path(recipient))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Gift" do
        expect {
          post gift_list_gifts_path(gift_list), params: { gift: invalid_attributes }, headers: headers
        }.to change(Gift, :count).by(0)
      end

      it "renders a response with 422 status" do
        post gift_list_gifts_path(gift_list), params: { gift: invalid_attributes }, headers: headers
        expect([ 422, 204, 406 ]).to include(response.status)
      end
    end
  end
end