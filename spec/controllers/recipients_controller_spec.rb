require 'rails_helper'

RSpec.describe RecipientsController, type: :controller do
  let(:user) do
      User.create!(
        name: 'Test User',
        email: 'chad_bro_chill@fakemail.com',
        password: 'lowkeybussin',
        password_confirmation: 'lowkeybussin')
  end

  let!(:event) do
    user.events.create!(
      name: "Beer oclock",
      event_date: Date.today + 4
    )
  end

  let(:valid_params) do
    {
      name: "Thad",
      age: 25,
      gender: "male",
      relation: "Bro",
      likes: [ "Reading", "Sports" ],
      dislikes: [ "Math" ],
      occupation: "Software Engineer",
      hobbies: "Coding and basketball",
      extra_info: "Hates animals"
    }
  end


  before do
    session[:session_token] = user.session_token
  end

  describe 'GET #index' do
    it 'assigns @recipients' do
      recipient1 = user.recipients.create!(valid_params)
      recipient2 = user.recipients.create!(valid_params.merge(name: "Brad"))

      get :index

      expect(assigns(:recipients)).to match_array([ recipient1, recipient2 ])
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'assigns a new recipient with no event' do
      get :new
      expect(assigns(:recipient)).to be_a_new(Recipient)
      expect(assigns(:from_event)).to be_falsey
      expect(assigns(:event_id)).to be_nil
      expect(response).to render_template(:new)
    end

    it "preserves event context when from_event is true" do
      get :new, params: { from_event: "true", event_id: event.id }
      expect(assigns(:recipient)).to be_a_new(Recipient)
      expect(assigns(:from_event)).to eq(true)
      expect(assigns(:event_id)).to eq(event.id.to_s)
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'without event context' do
      it "creates a new recipient for the current user" do
        expect do
          post :create, params: { recipient: valid_params }
        end.to change(user.recipients, :count).by(1)
      end

      it "sets the flash notice with the recipient's name" do
        post :create, params: { recipient: valid_params }
        expect(flash[:notice]).to eq("Thad was successfully created.")
      end

      it "redirects to the recipients index" do
        post :create, params: { recipient: valid_params }
        expect(response).to redirect_to(recipients_path)
      end
    end

    context "with event context" do
      it "creates the recipient and associates it with the event" do
        expect do
          post :create, params: {
            recipient: valid_params,
            from_event: "true",
            event_id: event.id
          }
        end.to change(user.recipients, :count).by(1)

        new_recipient = user.recipients.find_by!(name: "Thad")
        expect(event.recipients).to include(new_recipient)
      end

      it "redirects back to the event page with a notice" do
        post :create, params: {
          recipient: valid_params,
          from_event: "true",
          event_id: event.id
        }

        expect(response).to redirect_to(event_path(event))
        expect(flash[:notice]).to eq("Recipient created and added to event.")
      end
      context "with invalid params" do
        let(:invalid_params) do
          {
            name: "",
            gender: "",
            relation: "",
            age: nil,
            min_age: nil,
            birthday: nil
          }
        end

        it "does not create a new recipient" do
          expect do
            post :create, params: { recipient: invalid_params }
          end.not_to change(Recipient, :count)
        end

        it "re-renders the new template" do
          post :create, params: { recipient: invalid_params }

          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'GET #edit' do
    context "with invalid params" do
      let(:invalid_params) do
        {
          name: "",
          gender: "",
          relation: "",
          age: nil,
          min_age: nil,
          birthday: nil
        }
      end

      it "does not create a new recipient" do
        expect do
          post :create, params: { recipient: invalid_params }
        end.not_to change(Recipient, :count)
      end

      it "re-renders the new template" do
        post :create, params: { recipient: invalid_params }

        expect(response).to render_template(:new)
      end
    end
  end


  describe 'PATCH #update' do
    let!(:recipient) { user.recipients.create!(valid_params) }

    context "with valid params" do
      let(:updated_params) { { name: "Updated Thad" } }

      it "updates the recipient" do
        patch :update, params: { id: recipient.id, recipient: updated_params }

        expect(recipient.reload.name).to eq("Updated Thad")
      end

      it "sets the flash notice with the updated recipient's name" do
        patch :update, params: { id: recipient.id, recipient: updated_params }

        expect(flash[:notice]).to eq("Updated Thad was successfully updated.")
      end

      it "redirects to the recipient show page" do
        patch :update, params: { id: recipient.id, recipient: updated_params }

        expect(response).to redirect_to(recipient_path(recipient))
      end
    end

    context "with invalid params" do
      it "does not update the recipient and re-renders edit" do
        patch :update, params: { id: recipient.id, recipient: { name: "" } }

        expect(recipient.reload.name).to eq("Thad")
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'GET #show' do
    let!(:recipient) { user.recipients.create!(valid_params) }
    let(:ai_service) { instance_double(AiGiftService) }

    context "when cached suggestions exist" do
      it "assigns the requested recipient and loads suggestions" do
        expect(AiGiftService).to receive(:new).with(recipient).and_return(ai_service)
        allow(ai_service).to receive(:has_cached_suggestions?).and_return(true)
        allow(ai_service).to receive(:suggest_gift).and_return([ "Book", "T-Shirt" ])

        get :show, params: { id: recipient.id }

        expect(assigns(:recipient)).to eq(recipient)
        expect(assigns(:suggestions_exist)).to eq(true)
        expect(assigns(:suggestions)).to eq([ "Book", "T-Shirt" ])
        expect(response).to render_template(:show)
      end
    end
    context "when no cached suggestions exist" do
      it "assigns the recipient and leaves suggestions nil" do
        expect(AiGiftService).to receive(:new).with(recipient).and_return(ai_service)
        allow(ai_service).to receive(:has_cached_suggestions?).and_return(false)

        get :show, params: { id: recipient.id }

        expect(assigns(:recipient)).to eq(recipient)
        expect(assigns(:suggestions_exist)).to eq(false)
        expect(assigns(:suggestions)).to be_nil
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:recipient) { user.recipients.create!(valid_params) }

    it "destroys the recipient" do
      expect do
        delete :destroy, params: { id: recipient.id }
      end.to change(Recipient, :count).by(-1)
    end

    it "sets the flash notice" do
      delete :destroy, params: { id: recipient.id }

      expect(flash[:notice]).to eq("Recipient 'Thad' deleted.")
    end

    it "redirects to recipients_path" do
      delete :destroy, params: { id: recipient.id }

      expect(response).to redirect_to(recipients_path)
    end
  end
end
