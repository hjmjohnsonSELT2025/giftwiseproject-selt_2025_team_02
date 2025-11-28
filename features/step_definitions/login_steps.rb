Given("a user exists with email {string} and password {string}") do |email, password|
  user = User.find_or_initialize_by(email: email)
  user.name ||= email.split("@").first.capitalize
  user.password = password
  user.password_confirmation = password
  user.save!
  @user = user
end

Given('I am logged in as {string} with password {string}') do |email, password|
  step %(a user exists with email "#{email}" and password "#{password}")
  step "I go to the log in page"
  step %(I fill in "Email" with "#{email}")
  step %(I fill in "Password" with "#{password}")
  step %(I press "Log in")
  step "I should be logged in"
end

When(/^I fill in "([^"]+)" with "([^"]+)"$/) do |label, value|
  fill_in label, with: value
end

When(/^I press "([^"]+)"$/) do |text|
  click_button text
end

When("I go to the log in page") do
  if respond_to?(:login_path)
    visit login_path
  else
    visit "/login"
  end
end

Then("I should be on the log in page") do
  expected = respond_to?(:login_path) ? login_path : "/login"
  expect(page).to have_current_path(expected, ignore_query: true)
end

Then("I should be on the home page") do
  expected = respond_to?(:homepage_path) ? homepage_path : "/homepage"
  expect(page).to have_current_path(expected, ignore_query: true)
end

Then("I should be logged in") do
  has_logout = page.has_link?("Log out") || page.has_button?("Log out")
  expect(has_logout).to be(true), "Expected to find a 'Log out' link or button"
end

Then("I should not be logged in") do
  has_logout = page.has_link?("Log out") || page.has_button?("Log out")
  expect(has_logout).to be(false), "Did not expect to find a 'Log out' link or button"
end

Then('I should see {string} within the flash') do |words|
  flash_element = first(".flash, .alert, .notice, #flash", minimum: 1)
  expect(flash_element).to be_present
  expect(flash_element).to have_text(words)
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

When('I follow {string}') do |link_text|
  if link_text == "Delete"
    # Turbo DELETE links need this workaround in tests
    link = find_link(link_text)
    href = link[:href]
    page.driver.submit :delete, href, {}
  else
    click_link link_text
  end
end
