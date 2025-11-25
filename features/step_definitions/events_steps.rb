require "date"
require "bigdecimal"

# helper ruby methods
def find_user_by_name(name)
  User.find_by!(name: name)
end

def find_or_create_user_by_name(name)
  email = "#{name.downcase.gsub(/\s+/, "_")}@example.com"

  User.find_or_create_by!(email: email) do |u|
    u.name = name
    u.password = "password"
    u.password_confirmation = "password"
  end
end

def parse_relative_date(value)
  value = value.to_s.strip

  if (match = value.match(/\A(\d+)\s+days?\s+from\s+now\z/i))
    Date.current + match[1].to_i
  else
    Date.parse(value)
  end
end

def parse_event_attributes(hash)
  attrs = {}

  hash.each do |key, value|
    case key
    when "event_date"
      attrs[:event_date] = parse_relative_date(value)
    when "event_time"
      attrs[:event_time] = Time.zone.parse(value) if value && !value.strip.empty?
    when "location"
      attrs[:location] = value
    when "budget"
      attrs[:budget] = BigDecimal(value.to_s)
    else
      # ignore unknown keys for now
    end
  end

  attrs
end

# background steps

Given('a user {string} exists') do |name|
  @current_user = find_or_create_user_by_name(name)
end

Given('the user {string} has no events') do |name|
  user = find_or_create_user_by_name(name)
  user.events.destroy_all
end

# Scenario: Create an event with details

When('the user {string} creates an event called {string} with:') do |name, event_name, table|
  user = find_or_create_user_by_name(name)
  attrs = parse_event_attributes(table.rows_hash)

  event = user.events.create!(attrs.merge(name: event_name))
  @last_event = event
end

Then('the user {string} should have an event called {string}') do |name, event_name|
  user = find_or_create_user_by_name(name)
  event = user.events.find_by(name: event_name)

  expect(event).not_to be_nil
end

Then('the event {string} should have:') do |event_name, table|
  event = Event.find_by!(name: event_name)

  table.rows_hash.each do |key, expected|
    case key
    when "event_date"
      expected_date = parse_relative_date(expected)
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

# Scenario: Associate recipients with an event

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

  names = [recipient_name1, recipient_name2]

  names.each do |r_name|
    recipient =
      if @recipients_by_name && @recipients_by_name[r_name]
        @recipients_by_name[r_name]
      else
        Recipient.find_by!(name: r_name)
      end

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

  # check event → recipient
  expect(event.recipients.exists?(recipient.id)).to eq(true)

  # recipient event through association
  expect(recipient.events.exists?(event.id)).to eq(true)
end
