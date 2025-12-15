require 'rails_helper'
RSpec.describe "EventRecipientBudgets", type: :request do
  let(:user) do
    User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end
  let(:recipient) do
    Recipient.create!(
      name: "Test Recipient",
      user_id: user.id,
      gender: :male,
      relation: "Friend",
      age: 25
    )
  end
  let(:event) do
    Event.create!(
      name: "Christmas Party",
      event_date: Date.today + 7.days,
      user_id: user.id
    )
  end
  let!(:event_recipient) do
    EventRecipient.create!(
      event_id: event.id,
      source_recipient_id: recipient.id,
      snapshot: { name: recipient.name, age: recipient.age }
    )
  end
  let!(:budget_item) do
    EventRecipientBudget.create!(
      event_recipient_id: event_recipient.id,
      budget: 100.0,
      spent: 0.0
    )
  end
  let(:headers) { { "Accept" => "text/html" } }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end
  describe "GET /index" do
    it "returns http success" do
      get event_recipient_budgets_path, headers: headers
      expect(response).to have_http_status(:success)
    end

    it "returns http success with event selection" do
      get event_recipient_budgets_path(event_id: event.id), headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_event_recipient_budget_path(event_id: event.id, event_recipient_id: event_recipient.id), headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    let(:valid_params) do
      {
        event_id: event.id,
        event_recipient_id: event_recipient.id,
        event_recipient_budget: {
          budget: 500.0,
          spent: 50.0
        }
      }
    end

    let(:invalid_params) do
      {
        event_id: event.id,
        event_recipient_id: event_recipient.id,
        event_recipient_budget: {
          budget: -100
        }
      }
    end

    context "with valid parameters" do
      it "creates a new budget" do
        expect {
          post event_recipient_budgets_path, params: valid_params, headers: headers
        }.to change(EventRecipientBudget, :count).by(1)
      end

      it "redirects to the event show page" do
        post event_recipient_budgets_path, params: valid_params, headers: headers
        expect(response).to redirect_to(event_path(event))
      end
    end

    context "with invalid parameters" do
      it "does not create a new budget" do
        expect {
          post event_recipient_budgets_path, params: invalid_params, headers: headers
        }.not_to change(EventRecipientBudget, :count)
      end

      it "returns a failure status (422, 204, or 406)" do
        post event_recipient_budgets_path, params: invalid_params, headers: headers
        expect([ 422, 204, 406 ]).to include(response.status)
      end
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get edit_event_recipient_budget_path(budget_item), headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) { { budget: 999.0 } }

      it "updates the requested budget" do
        patch event_recipient_budget_path(budget_item), params: { event_recipient_budget: new_attributes }, headers: headers
        budget_item.reload
        expect(budget_item.budget).to eq(999.0)
      end

      it "redirects to the event page" do
        patch event_recipient_budget_path(budget_item), params: { event_recipient_budget: new_attributes }, headers: headers
        expect(response).to redirect_to(event_path(event))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { budget: -50.0 } }

      it "renders a failure status" do
        patch event_recipient_budget_path(budget_item), params: { event_recipient_budget: invalid_attributes }, headers: headers
        expect([ 422, 204, 406 ]).to include(response.status)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested budget" do
      expect {
        delete event_recipient_budget_path(budget_item), headers: headers
      }.to change(EventRecipientBudget, :count).by(-1)
    end

    it "redirects to the index list with the event_id preserved" do
      delete event_recipient_budget_path(budget_item), headers: headers
      expect(response).to redirect_to(event_recipient_budgets_path(event_id: event.id))
    end
  end

  describe "Security" do
    it "redirects users trying to access another user's budget" do
      other_user = User.create!(name: "Other", email: "other@example.com", password: "password", password_confirmation: "password")
      other_event = Event.create!(name: "Other Event", user_id: other_user.id, event_date: Date.today + 7.days)

      other_recipient = Recipient.create!(name: "Other Rec", user_id: other_user.id, gender: :male, relation: "Friend", age: 30)

      other_er = EventRecipient.create!(event_id: other_event.id, source_recipient_id: other_recipient.id, snapshot: {})
      other_budget = EventRecipientBudget.create!(event_recipient_id: other_er.id, budget: 10, spent: 0)
      get edit_event_recipient_budget_path(other_budget), headers: headers
      expect(response).to redirect_to(event_recipient_budgets_path)
    end
  end
end
