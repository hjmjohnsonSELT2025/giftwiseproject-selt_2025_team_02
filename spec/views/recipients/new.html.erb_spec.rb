require 'rails_helper'

RSpec.describe "recipients/new.html.erb", type: :view do
  let(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'password', password_confirmation: 'password') }

  before do
    assign(:recipient, Recipient.new)
    allow(view).to receive(:current_user).and_return(user)
  end

  it 'renders the new recipient form' do
    render
    expect(rendered).to have_selector('form')
  end
end
