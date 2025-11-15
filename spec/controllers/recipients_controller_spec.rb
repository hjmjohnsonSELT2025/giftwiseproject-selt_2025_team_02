require 'rails_helper'

RSpec.describe RecipientsController, type: :controller do
  let(:user) { User.create!(name: 'Test User', email: 'chad_bro_chill@fakemail.com', password: 'lowkeybussin', password_confirmation: 'lowkeybussin') }
  let(:recipient) { user.recipients.create!(name: 'John Doe', age: 30, gender: 'male', relation: 'friend') }

  before do
    session[:session_token] = user.session_token
  end

  describe 'GET #index' do
    it 'assigns @recipients' do
      get :index
      expect(assigns(:recipients)).to eq(user.recipients)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    it 'assigns a new recipient' do
      get :new
      expect(assigns(:recipient)).to be_a_new(Recipient)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) { { name: 'Jane Doe', age: 25, gender: 'female', relation: 'sister', likes: ['Reading'], dislikes: [] } }

      it 'creates a new recipient' do
        expect {
          post :create, params: { recipient: valid_params }
        }.to change(Recipient, :count).by(1)
      end

      it 'sets the flash notice' do
        post :create, params: { recipient: valid_params }
        expect(flash[:notice]).to eq('Jane Doe was successfully created.')
      end

      it 'redirects to recipients_path' do
        post :create, params: { recipient: valid_params }
        expect(response).to redirect_to(recipients_path)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested recipient' do
      get :edit, params: { id: recipient.id }
      expect(assigns(:recipient)).to eq(recipient)
    end

    it 'renders the edit template' do
      get :edit, params: { id: recipient.id }
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:update_params) { { name: 'John Smith' } }

      it 'updates the recipient' do
        patch :update, params: { id: recipient.id, recipient: update_params }
        recipient.reload
        expect(recipient.name).to eq('John Smith')
      end

      it 'sets the flash notice' do
        patch :update, params: { id: recipient.id, recipient: update_params }
        expect(flash[:notice]).to eq('John Smith was successfully updated.')
      end

      it 'redirects to the recipient' do
        patch :update, params: { id: recipient.id, recipient: update_params }
        expect(response).to redirect_to(recipient_path(recipient))
      end
    end
  end

  describe 'GET #show' do
    it 'assigns the requested recipient' do
      get :show, params: { id: recipient.id }
      expect(assigns(:recipient)).to eq(recipient)
    end

    it 'renders the show template' do
      get :show, params: { id: recipient.id }
      expect(response).to render_template(:show)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the recipient' do
      recipient # ensure it's created
      expect {
        delete :destroy, params: { id: recipient.id }
      }.to change(Recipient, :count).by(-1)
    end

    it 'sets the flash notice' do
      delete :destroy, params: { id: recipient.id }
      expect(flash[:notice]).to eq("Recipient 'John Doe' deleted.")
    end

    it 'redirects to recipients_path' do
      delete :destroy, params: { id: recipient.id }
      expect(response).to redirect_to(recipients_path)
    end
  end
end
