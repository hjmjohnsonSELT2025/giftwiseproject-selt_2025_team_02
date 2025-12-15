require "rails_helper"
RSpec.describe ApplicationMailer, type: :mailer do
  describe "configuration" do
    it "sets the default from address" do
      expect(ApplicationMailer.default[:from]).to eq("from@example.com")
    end
    it "uses the correct layout" do
      expect(ApplicationMailer._layout).to eq("mailer")
    end
  end
end
