require 'rails_helper'

RSpec.describe "Recipients", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/recipients/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/recipients/create"
      expect(response).to have_http_status(:success)
    end
  end
end
