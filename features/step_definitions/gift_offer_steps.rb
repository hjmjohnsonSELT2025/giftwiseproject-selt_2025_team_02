# features/step_definitions/gift_offer_steps.rb

Given('there are no gift lists') do
  GiftList.destroy_all
end

Given('there are no purchase options') do
  GiftOffer.destroy_all
end

Given('a recipient {string} exists for this user') do |name|
  raise 'Missing @user; make sure a user is created first' unless @user

  @recipient = @user.recipients.create!(
    name:      name,
    age:       30,
    gender:    :other,
    relation:  'Friend',
    likes:     [],
    dislikes:  []
  )
end

Given('a gift list {string} exists for {string}') do |list_name, recipient_name|
  @recipient ||= @user.recipients.find_by!(name: recipient_name)

  @gift_list = @recipient.gift_lists.find_or_create_by!(name: list_name)
end

Given('a gift {string} exists on the {string} gift list') do |gift_name, list_name|
  @gift_list = GiftList.find_or_create_by!(name: list_name, recipient: @recipient)

  @gift = @gift_list.gifts.find_or_create_by!(
    name: gift_name
  )

  # Ensure the page reflects the newly created gift if we're already on the list page
  visit recipient_gift_list_path(@gift_list.recipient, @gift_list)
end

Given('I am on the {string} gift list page') do |list_name|
  @gift_list ||= GiftList.find_by!(name: list_name, recipient: @recipient)
  @recipient ||= @gift_list.recipient

  visit recipient_gift_list_path(@recipient, @gift_list)
end

When('I view the gift {string} from the {string} gift list') do |gift_name, list_name|
  gift_list = GiftList.find_by!(name: list_name, recipient: @recipient)
  gift      = gift_list.gifts.find_by!(name: gift_name)

  # Gifts are nested under recipient and gift_list
  visit recipient_gift_list_gift_path(gift_list.recipient, gift_list, gift)
end

Then('I should be on the gift detail page for {string}') do |gift_name|
  gift      = Gift.find_by!(name: gift_name)
  gift_list = gift.gift_list
  recipient = gift_list.recipient

  expect(current_path).to eq(
                            recipient_gift_list_gift_path(recipient, gift_list, gift)
                          )
end

Then('{int} purchase option should exist for the gift {string}') do |count, gift_name|
  gift = Gift.find_by!(name: gift_name)

  # This will start failing until:
  #   has_many :gift_offers
  # to Gift, and create the GiftOffer model/table
  expect(gift.gift_offers.count).to eq(count)
end
