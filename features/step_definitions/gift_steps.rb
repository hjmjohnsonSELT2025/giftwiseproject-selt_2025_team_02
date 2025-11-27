# features/step_definitions/gift_steps.rb

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

Then("I should be on the gifts page") do
  expected = respond_to?(:gifts_path) ? gifts_path : "/gifts"
  expect(page).to have_current_path(expected, ignore_query: true)
end
