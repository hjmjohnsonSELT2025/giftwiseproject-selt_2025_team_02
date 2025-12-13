require "rails_helper"

RSpec.describe User, type: :model do
  let(:valid_attributes) do
    {
      name:                  "Chad Bro Chill",
      email:                 "chad_bro_chill@fakemail.com",
      password:              "lowkeybussin",
      password_confirmation: "lowkeybussin"
    }
  end

  describe "validations" do
    it "is valid with a name, email, and matching password and confirmation" do
      user = User.new(valid_attributes)
      expect(user).to be_valid
    end

    it "is invalid without a name" do
      user = User.new(valid_attributes.merge(name: ""))
      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it "limits name length to 50 characters" do
      user = User.new(valid_attributes.merge(name: "L" * 51))
      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it "is invalid without an email" do
      user = User.new(valid_attributes.merge(email: ""))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "requires email to have a valid format" do
      user = User.new(valid_attributes.merge(email: "not-an-email"))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it "downcases email before save" do
      user = User.create!(valid_attributes.merge(email: "CHAD_BRO_CHILL@FAKEMAIL.COM"))
      expect(user.reload.email).to eq("chad_bro_chill@fakemail.com")
    end

    it "requires email to be unique (case insensitive)" do
      User.create!(valid_attributes.merge(email: "chad_bro_chill@fakemail.com"))
      duplicate = User.new(valid_attributes.merge(email: "CHAD_BRO_CHILL@FAKEMAIL.COM"))

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end

    it "requires a password on create" do
      user = User.new(valid_attributes.except(:password, :password_confirmation))

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "enforces a minimum password length of 6 characters" do
      user = User.new(
        valid_attributes.merge(password: "beer", password_confirmation: "beer")
      )

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it "requires password confirmation to match" do
      user = User.new(
        valid_attributes.merge(password_confirmation: "different")
      )

      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to be_present
    end

    it "allows updating other attributes without changing the password" do
      user = User.create!(valid_attributes)
      user.assign_attributes(name: "New Name", password: "lowkeybussin", password_confirmation: "lowkeybussin")

      expect(user).to be_valid
      expect(user.save).to be true
      expect(user.reload.name).to eq("New Name")
    end

    it "still enforces password rules when a new password is provided on update" do
      user = User.create!(valid_attributes)
      user.assign_attributes(password: "beer", password_confirmation: "beer")

      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end
  end

  describe "password authentication" do
    it "authenticates with the correct password" do
      user = User.create!(valid_attributes)

      expect(user.authenticate("lowkeybussin")).to eq(user)
    end

    it "does not authenticate with an incorrect password" do
      user = User.create!(valid_attributes)

      expect(user.authenticate("highkeybussin")).to be_falsey
    end
  end

  describe "session token" do
    it "generates a session_token on create if missing" do
      user = User.create!(valid_attributes.merge(session_token: nil))

      expect(user.session_token).to be_present
    end

    it "reset_session_token! returns a new token and persists it" do
      user = User.create!(valid_attributes)
      old_token = user.session_token
      new_token = user.reset_session_token!

      expect(new_token).to be_present
      expect(new_token).not_to eq(old_token)
      expect(user.reload.session_token).to eq(new_token)
    end
  end
end
