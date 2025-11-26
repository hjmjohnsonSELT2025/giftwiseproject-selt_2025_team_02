require "date"
require "bigdecimal"

def find_or_create_user_by_name(name)
  email = "#{name.downcase.gsub(/\s+/, "_")}@example.com"

  User.find_or_create_by!(email: email) do |u|
    u.name = name
    u.password = "password"
    u.password_confirmation = "password"
  end
end

def current_scenario_user
  @user || User.find_by!(email: "chad_bro_chill@fakemail.com")
end

def parse_relative_or_absolute_date(value)
  value = value.to_s.strip

  if (match = value.match(/\A(\d+)\s+days?\s+from\s+now\z/i))
    Date.current + match[1].to_i
  else
    Date.parse(value)
  end
end

Given('a user {string} exists') do |name|
  @current_user_for_model_steps = find_or_create_user_by_name(name)
end

Given('the user {string} has no events') do |name|
  user = find_or_create_user_by_name(name)
  user.events.destroy_all
end

Given('there are no previous events for this user') do
  user = current_scenario_user
  user.events.destroy_all
end

Given('I am on the events page') do
  visit respond_to?(:events_path) ? events_path : "/events"
end

When('I click {string}') do |label|
  click_link_or_button(label)
end

Given('the following events exist for this user:') do |table|
  user = current_scenario_user

  table.hashes.each do |row|
    attrs = {}
    attrs[:name]       = row["name"] if row["name"].present?
    attrs[:event_date] = Date.parse(row["event_date"]) if row["event_date"].present?
    attrs[:event_time] = Time.zone.parse(row["event_time"]) if row["event_time"].present?
    attrs[:location]   = row["location"] if row["location"].present?
    attrs[:budget]     = BigDecimal(row["budget"]) if row["budget"].present?

    user.events.create!(attrs)
  end
end

Then('I should be on the events page') do
  expected = respond_to?(:events_path) ? events_path : "/events"
  expect(page).to have_current_path(expected)
end

Then('the event {string} should have:') do |event_name, table|
  event = Event.find_by!(name: event_name)

  table.rows_hash.each do |key, expected|
    case key
    when "event_date"
      expected_date = parse_relative_or_absolute_date(expected)
      expect(event.event_date).to eq(expected_date)
    when "event_time"
      expect(event.event_time.strftime("%H:%M")).to eq(expected.strip)
    when "location"
      expect(event.location).to eq(expected)
    when "budget"
      expect(event.budget.to_f).to eq(expected.to_f)
    else
      raise "Unknown event attribute in step: #{key.inspect}"
    end
  end
end

Given('the user {string} has a recipient named {string}') do |user_name, recipient_name|
  user = find_or_create_user_by_name(user_name)

  @recipients_by_name ||= {}
  recipient = user.recipients.find_or_create_by!(name: recipient_name) do |r|
    r.age      = 25
    r.gender   = :male
    r.relation = "Friend"
    r.likes    = []
    r.dislikes = []
  end

  @recipients_by_name[recipient_name] = recipient
end

Given('the user {string} has an event called {string}') do |user_name, event_name|
  user = find_or_create_user_by_name(user_name)

  event = user.events.find_or_create_by!(name: event_name) do |e|
    e.event_date = Date.current + 1
    e.event_time = Time.zone.parse("18:00")
    e.location   = "Default Location"
    e.budget     = BigDecimal("0")
  end

  @last_event = event
end

When('the recipients {string} and {string} are added to the event {string}') do |recipient_name1, recipient_name2, event_name|
  event = Event.find_by!(name: event_name)
  names = [ recipient_name1, recipient_name2 ]

  @recipients_by_name ||= {}

  names.each do |r_name|
    recipient =
      @recipients_by_name[r_name] ||
      Recipient.find_by!(name: r_name)

    event.recipients << recipient unless event.recipients.exists?(recipient.id)
  end

  @last_event = event
end

Then('the event {string} should have recipients:') do |event_name, table|
  event = Event.find_by!(name: event_name)
  expected_names = table.raw.flatten
  actual_names = event.recipients.map(&:name)

  expect(actual_names).to match_array(expected_names)
end

Then('the recipient {string} should be associated with the event {string}') do |recipient_name, event_name|
  event = Event.find_by!(name: event_name)
  recipient = Recipient.find_by!(name: recipient_name)

  expect(event.recipients.exists?(recipient.id)).to eq(true)
  expect(recipient.events.exists?(event.id)).to eq(true)
end

Then('I should not see {string} in the events list') do |event_name|
  if page.has_css?('table')
    # There is an events table so check inside it
    within('table') do
      expect(page).not_to have_content(event_name)
    end
  else
    # No events table means there is no list at all
    true
  end
end

Then('I should see {string} in the recipients section') do |recipient_name|
  within(:xpath, "//h2[contains(., 'Recipients for this event')]/following-sibling::ul[1]") do
    expect(page).to have_content(recipient_name)
  end
end

Then('I should not see {string} in the recipients section') do |recipient_name|
  recipients_xpath = "//h2[contains(., 'Recipients for this event')]/following-sibling::ul[1]"

  if page.has_xpath?(recipients_xpath)
    within(:xpath, recipients_xpath) do
      expect(page).not_to have_content(recipient_name)
    end
  end
end

When('I follow {string} within the {string} row') do |link_text, recipient_name|
  within(:xpath, "//h2[contains(., 'Recipients for this event')]/following-sibling::ul[1]//li[contains(., '#{recipient_name}')]") do
    link = find_link(link_text, exact: true)
    href = link[:href]
    page.driver.submit :delete, href, {}
  end
end
