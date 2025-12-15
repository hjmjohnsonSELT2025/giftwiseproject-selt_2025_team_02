require 'rails_helper'

RSpec.describe "Home", type: :request do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password", password_confirmation: "password") }
  let!(:recipient) { Recipient.create!(name: "Nancy", user_id: user.id, gender: :female, relation: "Friend", age: 25) }
  let!(:event) { Event.create!(name: "Christmas", event_date: Date.today + 10.days, user_id: user.id) }

  let!(:event_recipient) do
    EventRecipient.create!(
      event_id: event.id,
      source_recipient_id: recipient.id,
      snapshot: { name: recipient.name }
    )
  end

  let!(:budget) do
    EventRecipientBudget.create!(
      event_recipient_id: event_recipient.id,
      budget: 100.0,
      spent: 0.0
    )
  end

  let(:headers) { { "Accept" => "text/html" } }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow(user).to receive(:active_gifts_grouping).and_return({ idea: 5, purchased: 2 })
  end

  describe "GET /show" do
    context "default behavior" do
      it "returns http success" do
        get root_path, headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context "with tab parameters" do
      it "loads the events tab" do
        get root_path(tab: "events"), headers: headers
        expect(response).to have_http_status(:success)
      end

      it "loads the budgets tab" do
        get root_path(tab: "budgets"), headers: headers
        expect(response).to have_http_status(:success)
      end

      it "falls back to overview for invalid tabs" do
        get root_path(tab: "invalid_tab_name"), headers: headers
        expect(response).to have_http_status(:success)
      end
    end
  end
end