require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  let!(:user) do
    User.create!(
      name: "Chad",
      email: "chad_bro_chill@fakemail.com",
      password: "lowkeybussin",
      password_confirmation: "lowkeybussin"
    )
  end

  describe "GET #new" do
    it "renders the login page" do
      get :new
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid credentials" do
      it "resets the session token and redirects to homepage" do
        old_token = user.session_token

        post :create, params: {
          session: {
            email: user.email,
            password: "lowkeybussin"
          }
        }

        user.reload

        expect(user.session_token).not_to eq(old_token)
        expect(response).to redirect_to(homepage_path)
        expect(flash[:notice]).to eq("Logged in!")
      end
    end

    context "with invalid credentials" do
      it "re-renders the login page with warning" do
        post :create, params: {
          session: {
            email: user.email,
            password: "wrongpassword"
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(flash.now[:warning]).to eq("Incorrect email and/or password")
      end
    end
  end

  describe "DELETE #destroy" do
    it "resets the session token and logs the user out" do
      session[:session_token] = user.session_token

      delete :destroy

      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq("Signed out")
    end
  end
end
