require 'rails_helper'

RSpec.describe "GiftLists", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/gift_lists/index"
      expect(response).to have_http_status(:success)
    end
  end
end
