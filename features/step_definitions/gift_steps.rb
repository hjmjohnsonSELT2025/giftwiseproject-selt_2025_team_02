# features/step_definitions/gift_steps.rb

# Reuse login behavior for this branch
Given("I am logged in as {string} with password {string}") do |email, password|
  step %(a user exists with email "#{email}" and password "#{password}")
  step "I go to the log in page"
  step %(I fill in "Email" with "#{email}")
  step %(I fill in "Password" with "#{password}")
  step %(I press "Log in")
  step "I should be logged in"
end

Given("there are no gifts") do
  Gift.destroy_all
end

Given("I am on the gifts page") do
  path = respond_to?(:gifts_path) ? gifts_path : "/gifts"
  visit path
end

When("I go to the new gift page") do
  path = respond_to?(:new_gift_path) ? new_gift_path : "/gifts/new"
  visit path
end

Then("{int} gifts should exist for the current user") do |count|
  raise "@user is not set; make sure you logged in first" unless @user

  actual = Gift.where(user_id: @user.id.to_s).count
  expect(actual).to eq(count)
end

Then("{int} gift should exist for the current user") do |count|
  step "#{count} gifts should exist for the current user"
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then("I should be on the gifts page") do
  expected = respond_to?(:gifts_path) ? gifts_path : "/gifts"
  expect(page).to have_current_path(expected, ignore_query: true)
end

When('I follow {string}') do |link_text|
  click_link link_text
end