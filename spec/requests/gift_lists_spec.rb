require 'rails_helper'

RSpec.describe "GiftLists", type: :request do
  let(:user) do
    User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  let!(:recipient) do
    Recipient.create!(
      name: "Test Recipient",
      user_id: user.id,
      gender: :male,
      relation: "Friend",
      age: 25
    )
  end

  let(:valid_attributes) do
    {
      name: "Birthday Wishlist",
      recipient_id: recipient.id
    }
  end

  let(:invalid_attributes) do
    {
      name: "",
      recipient_id: recipient.id
    }
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /index" do
    it "returns http success" do
      GiftList.create!(valid_attributes)
      get gift_lists_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_gift_list_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      gift_list = GiftList.create!(valid_attributes)
      get gift_list_path(gift_list)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new GiftList" do
        expect {
          post gift_lists_path, params: { gift_list: valid_attributes }
        }.to change(GiftList, :count).by(1)
      end

      it "redirects to the recipient page" do
        post gift_lists_path, params: { gift_list: valid_attributes }
        new_list = GiftList.last
        expect(response).to redirect_to(recipient_path(new_list.recipient))
      end
    end

    context "with invalid parameters" do
      it "does not create a new GiftList" do
        expect {
          post gift_lists_path, params: { gift_list: invalid_attributes }
        }.to change(GiftList, :count).by(0)
      end

      it "renders a response with 422 status" do
        post gift_lists_path, params: { gift_list: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end