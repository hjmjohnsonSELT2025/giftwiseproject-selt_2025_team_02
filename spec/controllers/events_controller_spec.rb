require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) do
    User.create!(
      name: 'Chad',
      email: 'chad_bro_chill@fakemail.com',
      password: 'lowkeybussin',
      password_confirmation: 'lowkeybussin'
    )
  end

  let!(:event) do
    user.events.create!(
      name: 'Beer oclock',
      event_date: Date.today + 4,
      event_time: Time.zone.parse('18:00'),
      location: 'Downtown',
      budget: 50
    )
  end

  before do
    session[:session_token] = user.session_token
  end

  describe 'index' do
    it 'assigns @events for the current user' do
      another_event = user.events.create!(
        name: 'Game night',
        event_date: Date.today + 2
      )

      get :index

      expect(assigns(:events)).to match_array([ event, another_event ])
      expect(response).to render_template(:index)
    end
  end

  describe 'new' do
    it 'assigns a new event' do
      get :new

      expect(assigns(:event)).to be_a_new(Event)
      expect(response).to render_template(:new)
    end
  end

  describe 'create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          name: 'Work Christmas Party',
          event_date: Date.today + 5,
          event_time: '18:00',
          location: 'Office',
          budget: 100
        }
      end

      it 'creates a new event for the current user' do
        expect do
          post :create, params: { event: valid_params }
        end.to change(user.events, :count).by(1)
      end

      it "sets the flash notice with the event's name" do
        post :create, params: { event: valid_params }

        expect(flash[:notice]).to eq("Event 'Work Christmas Party' successfully created.")
      end

      it 'redirects to the event show page' do
        post :create, params: { event: valid_params }

        new_event = Event.find_by!(name: 'Work Christmas Party')
        expect(response).to redirect_to(event_path(new_event))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { name: '', event_date: nil } }

      it 'does not create a new event' do
        expect do
          post :create, params: { event: invalid_params }
        end.not_to change(Event, :count)
      end

      it 're-renders the new template' do
        post :create, params: { event: invalid_params }

        expect(response).to render_template(:new)
      end
    end
  end

  describe 'edit' do
    it 'assigns the requested event' do
      get :edit, params: { id: event.id }

      expect(assigns(:event)).to eq(event)
      expect(response).to render_template(:edit)
    end
  end

  describe 'show' do
    it 'assigns the requested event' do
      get :show, params: { id: event.id }

      expect(assigns(:event)).to eq(event)
      expect(response).to render_template(:show)
    end
  end

  describe 'update' do
    context 'with valid params' do
      let(:updated_params) { { name: 'Updated Event Name' } }

      it 'updates the event' do
        patch :update, params: { id: event.id, event: updated_params }

        expect(event.reload.name).to eq('Updated Event Name')
      end

      it "sets the flash notice with the updated event's name" do
        patch :update, params: { id: event.id, event: updated_params }

        expect(flash[:notice]).to eq("Event 'Updated Event Name' successfully updated.")
      end

      it 'redirects to the event show page' do
        patch :update, params: { id: event.id, event: updated_params }

        expect(response).to redirect_to(event_path(event))
      end
    end

    context 'with invalid params' do
      it 'does not update the event and re-renders edit' do
        patch :update, params: { id: event.id, event: { name: '' } }

        expect(event.reload.name).to eq('Beer oclock')
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'destroy' do
    it 'destroys the event' do
      expect do
        delete :destroy, params: { id: event.id }
      end.to change(Event, :count).by(-1)
    end

    it 'sets the flash notice' do
      delete :destroy, params: { id: event.id }

      expect(flash[:notice]).to eq("Event 'Beer oclock' deleted.")
    end

    it 'redirects to events_path' do
      delete :destroy, params: { id: event.id }

      expect(response).to redirect_to(events_path)
    end
  end
end
