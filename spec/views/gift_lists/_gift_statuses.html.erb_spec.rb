require 'rails_helper'

RSpec.describe "gift_lists/_gift_statuses.html.erb", type: :view do
  it "renders Stimulus sortable columns with gift cards and Save button" do
    user = User.create!(name: "Tester", email: "tester2@example.com", password: "password", password_confirmation: "password")
    recipient = Recipient.create!(user: user, name: "Nancy", age: 28, gender: :other, relation: "Sibling", birthday: Date.new(1997, 5, 5))
    list = GiftList.create!(recipient: recipient, name: "General ideas")

    # Create one gift in two different statuses to verify placement and attributes
    idea_gift = list.gifts.create!(name: "Book", status: :idea)
    planned_gift = list.gifts.create!(name: "Puzzle", status: :planned)

    render partial: "gift_lists/gift_statuses", locals: { list: list }

    # Root container has Stimulus controller and group value
    expect(rendered).to include('data-controller="sortable"')
    expect(rendered).to include("data-sortable-group-value=\"gifts-list-#{list.id}\"")

    # Columns for each status present and marked as targets with status value
    Gift.statuses.keys.each do |status|
      expect(rendered).to include('data-sortable-target="column"')
      expect(rendered).to include("data-status=\"#{status}\"")
    end

    # Gift cards include data attributes used by JS: id, original-status, and url
    expect(rendered).to include("data-id=\"#{idea_gift.id}\"")
    expect(rendered).to include("data-original-status=\"#{idea_gift.status}\"")
    expect(rendered).to include("/gift_lists/#{list.id}/gifts/#{idea_gift.id}")

    expect(rendered).to include("data-id=\"#{planned_gift.id}\"")
    expect(rendered).to include("data-original-status=\"#{planned_gift.status}\"")
    expect(rendered).to include("/gift_lists/#{list.id}/gifts/#{planned_gift.id}")

    # Save button triggers sortable#save
    expect(rendered).to include('data-action="click->sortable#save"')
  end
end
