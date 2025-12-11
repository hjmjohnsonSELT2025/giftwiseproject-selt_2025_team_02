require 'date'

# Given("I am logged in as {string} with password {string}") do |email, password|
#   step %(a user exists with email "#{email}" and password "#{password}")
#   @user = User.find_by(email: email)
#   step "I go to the log in page"
#   step %(I fill in "Email" with "#{email}")
#   step %(I fill in "Password" with "#{password}")
#   step %(I press "Log in")
#   step "I should be logged in"
# end

Given("there are no recipients for this user") do
  raise "@user is not set; make sure you logged in first" unless @user
  @user.recipients.destroy_all
end

Given("I am on the recipients page") do
  visit (respond_to?(:recipients_path) ? recipients_path : "/recipients")
end

Then("I should be on the recipients page") do
  expected = respond_to?(:recipients_path) ? recipients_path : "/recipients"
  expect(page).to have_current_path(expected, ignore_query: true)
end

Then("I should be on the add recipient page") do
  expected = respond_to?(:new_recipient_path) ? new_recipient_path : "/recipients/new"
  expect(page).to have_current_path(expected, ignore_query: true)
end

Then("{int} recipients should exist for the current user") do |count|
  raise "@user is not set" unless @user
  expect(@user.recipients.count).to eq(count)
end

# When("I follow {string}") do |link_text|
#   if link_text == "Delete"
#     # Turbo's data-turbo-method needs JS; in tests we simulate the DELETE directly
#     link = find_link(link_text)
#     href = link[:href]
#     page.driver.submit :delete, href, {}
#   else
#     click_link link_text
#   end
# end

When("I select {string} from {string}") do |option, field|
  select option, from: field
end

When("I check {string}") do |label|
  check label
end

When(/^I click "([^"]+)"$/) do |text|
  click_button text
end


# Then("I should see {string}") do |text|
#   expect(page).to have_content(text)
# end

Given("the following recipients exist for this user:") do |table|
  raise "@user is not set; make sure you logged in first" unless @user

  table.hashes.each do |row|
    # use provided birthday string if present (MM/DD/YYYY)
    # otherwise make an approximate birthday from provided age
    birthday = nil
    birthday_value = row["birthday"].to_s.strip
    if !birthday_value.empty?
      begin
        birthday = Date.strptime(birthday_value, "%m/%d/%Y")
      rescue ArgumentError
        birthday = Date.parse(birthday_value) rescue nil
      end
    elsif row["age"].to_s.strip != ""
      age_i = row["age"].to_i
      today = Date.today
      # approximate: birthday on Jan 1 of (current_year - age)
      birthday = Date.new(today.year - age_i, 1, 1) rescue nil
    end

    @user.recipients.create!(
      name: row["name"],
      age: row["age"],
      gender: row["gender"],
      relation: row["relation"],
      birthday: birthday,
      likes: [],
      dislikes: []
    )
  end
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end

Then("I should not see {string} in the recipients list") do |name|
  # Limit the check to the recipients table (index view)
  within("table") do
    expect(page).not_to have_content(name)
  end
end

Given("the AI service will return {string}") do |gift_name|
  fake_suggestions = {
    gift_name => "Because she likes knitting"
  }
  # use allow_any_instance_of because the controller creates a new instance
  allow_any_instance_of(AiGiftService).to receive(:suggest_gift).and_return(fake_suggestions)

  # also need to mock this so controller knows to show the results
  allow_any_instance_of(AiGiftService).to receive(:has_cached_suggestions?).and_return(true)
end

Given(/^the OpenAI service is currently down$/) do
  allow_any_instance_of(AiGiftService).to receive(:suggest_gift).and_raise(StandardError, "API Timeout")
  # make sure controller ignores cached data, so it tries to fetch
  allow_any_instance_of(AiGiftService).to receive(:has_cached_suggestions?).and_return(false)
end
