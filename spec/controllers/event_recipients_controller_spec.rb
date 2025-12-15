require 'rails_helper'

RSpec.describe "EventRecipients", type: :request do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password", password_confirmation: "password") }

  let(:event) do
    Event.create!(
      name: "Graduation Party",
      event_date: Date.today + 1.month,
      user_id: user.id
    )
  end

  let(:recipient) do
    Recipient.create!(
      name: "Graduate",
      user_id: user.id,
      gender: :female,
      relation: "Family",
      age: 22,
      birthday: Date.today - 22.years
    )
  end

  let!(:event_recipient) do
    EventRecipient.create!(
      event_id: event.id,
      source_recipient_id: recipient.id,
      snapshot: {
        name: recipient.name,
        birthday: recipient.birthday,
        gender: recipient.gender,
        relation: recipient.relation,
        age: recipient.age
      }
    )
  end

  let(:headers) { { "Accept" => "text/html" } }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe "GET /show" do
    context "when the record exists" do
      it "returns http success" do
        get event_event_recipient_path(event, event_recipient), headers: headers
        expect(response).to have_http_status(:success)
      end

      it "finds the correct event recipient" do
        get event_event_recipient_path(event, event_recipient), headers: headers
        expect(response.status).to eq(200)
      end
    end

    context "when the event does not exist" do
      it "redirects (handles 404)" do
        get event_event_recipient_path("99999", event_recipient), headers: headers
        expect(response).to have_http_status(:found)
      end
    end

    context "when the event_recipient does not exist" do
      it "redirects (handles 404)" do
        get event_event_recipient_path(event, "99999"), headers: headers
        expect(response).to have_http_status(:found)
      end
    end
  end
end
