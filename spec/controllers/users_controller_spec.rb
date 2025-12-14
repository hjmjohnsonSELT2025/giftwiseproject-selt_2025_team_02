require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let!(:user) do
    User.create!(
      name: "Chad",
      email: "chad_bro_chill@fakemail.com",
      password: "lowkeybussin",
      password_confirmation: "lowkeybussin"
    )
  end

  def log_in_as(user)
    token = user.reset_session_token!
    session[:session_token] = token
    token
  end

  describe "GET #new" do
    it "assigns a new user and renders :new" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        user: {
          name: "Chad",
          email: "chads_other_email@fakemail.com",
          password: "lowkeybussin",
          password_confirmation: "lowkeybussin"
        }
      }
    end

    it "creates the user, sets session token, and redirects to homepage with notice" do
      predictable_token = "token123"
      allow_any_instance_of(User).to receive(:reset_session_token!).and_return(predictable_token)

      expect { post :create, params: valid_params }.to change(User, :count).by(1)

      expect(session[:session_token]).to eq(predictable_token)
      expect(response).to redirect_to(homepage_path)
      expect(flash[:notice]).to eq("Account created successfully.")
    end

    it "renders :new with warning when save fails" do
      user_double = instance_double(User, save: false)
      allow(User).to receive(:new).and_return(user_double)

      post :create, params: valid_params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
      expect(flash[:warning]).to eq("There was a problem creating your account.")
    end
  end

  describe "GET #show" do
    context "when not logged in" do
      it "redirects to login" do
        get :show, params: { id: user.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { log_in_as(user) }

      it "renders :show and assigns @user when id matches current user" do
        get :show, params: { id: user.id }

        expect(assigns(:user)).to eq(user)
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:show)
      end

      it "redirects to homepage with warning when id does not match current user" do
        other_user = User.create!(
          name: "Brad",
          email: "brad_mail@fakemail.com",
          password: "skibidi_67",
          password_confirmation: "skibidi_67"
        )

        get :show, params: { id: other_user.id }

        expect(response).to redirect_to(homepage_path)
        expect(flash[:warning]).to eq("Can only show profile of logged in user!")
      end
    end
  end

  describe "GET #edit" do
    context "when not logged in" do
      it "redirects to login" do
        get :edit, params: { id: user.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { log_in_as(user) }

      it "renders :edit and assigns @user when id matches current user" do
        get :edit, params: { id: user.id }

        expect(assigns(:user)).to eq(user)
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:edit)
      end

      it "redirects to homepage with warning when id does not match current user" do
        other_user = User.create!(
          name: "Thad",
          email: "thad_mail@fakemail.com",
          password: "highkeybussin",
          password_confirmation: "highkeybussin"
        )

        get :edit, params: { id: other_user.id }

        expect(response).to redirect_to(homepage_path)
        expect(flash[:warning]).to eq("Can only edit profile of logged in user!")
      end
    end
  end

  describe "PATCH #update" do
    context "when not logged in" do
      it "redirects to login" do
        patch :update, params: { id: user.id, user: { name: "Lad" } }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before { log_in_as(user) }

      it "redirects to homepage with warning when id does not match current user and returns early" do
        other_user = User.create!(
          name: "Blaze",
          email: "blaze_mail@fakemail.com",
          password: "globogym",
          password_confirmation: "globogym"
        )

        patch :update, params: { id: other_user.id, user: { name: "Laser" } }

        expect(response).to redirect_to(homepage_path)
        expect(flash[:warning]).to eq("Can only update profile of logged in user!")
      end

      it "updates allowed fields and redirects to user show with notice when update succeeds" do
        patch :update, params: { id: user.id, user: { name: "Blazer" } }

        expect(user.reload.name).to eq("Blazer")
        expect(response).to redirect_to(user_path(user))
        expect(flash[:notice]).to eq("Profile updated successfully.")
      end

      it "renders :edit when update fails" do
        allow_any_instance_of(User).to receive(:update).and_return(false)

        patch :update, params: { id: user.id, user: { name: "Big Bear" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end

      it "does not permit email changes on update" do
        original_email = user.email

        patch :update, params: {
          id: user.id,
          user: { name: "Still Chad", email: "hacked@fakemail.com" }
        }

        user.reload
        expect(user.name).to eq("Still Chad")
        expect(user.email).to eq(original_email)
      end
    end
  end
end
