 require 'rails_helper'

RSpec.describe "Gift status drag-and-drop API", type: :request do
  describe "PATCH /gift_lists/:gift_list_id/gifts/:id" do
    it "updates the gift status via JSON and returns success" do
      user = User.create!(name: "Tester", email: "tester@example.com", password: "password", password_confirmation: "password")
      recipient = Recipient.create!(user: user, name: "Alex", age: 30, gender: :other, relation: "Friend", birthday: Date.new(1995, 1, 1))
      list = GiftList.create!(recipient: recipient, name: "General ideas")
      gift = list.gifts.create!(name: "Cozy Socks", status: :idea)

      # Simulate logged-in user by stubbing current_user on ApplicationController
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      patch gift_list_gift_path(list, gift, format: :json),
            params: { gift: { status: "planned" } }.to_json,
            headers: { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["status"]).to eq("success")
      expect(body["gift"]).to be_present
      expect(gift.reload.status).to eq("planned")
    end
  end
end
