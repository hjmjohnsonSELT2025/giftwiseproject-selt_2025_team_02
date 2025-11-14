Given("a user exists with email {string} and password {string}") do |email, password|
  @user = User.create!(email: email, password: password, password_confirmation: password)
end

When("I go to the log in page") do
  visit "/login"
end

Then("I should be on the log in page") do
end

Then("I should be on the home page") do
end

Then("I should be logged in") do
end

Then("I should not be logged in") do
end

Then('I should see {string} within the flash') do |words|
end
