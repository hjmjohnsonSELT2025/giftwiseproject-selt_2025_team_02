# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.find_or_create_by!(email: "chad_bro_chill@fakemail.com") do |u|
  u.name  = "Chad"
  u.password = "lowkeybussin"
  u.password_confirmation = "lowkeybussin"
end

recipient1 = user.recipients.find_or_create_by!(name: "Thad") do |r|
  r.age       = 20
  r.gender    = :male
  r.relation  = "Bro"
  r.likes     = %w[Yoga Meditation]
  r.dislikes  = %w[Math]
end

recipient2 = user.recipients.find_or_create_by!(name: "Brad") do |r|
  r.age       = 21
  r.gender    = :male
  r.relation  = "Bro"
  r.likes     = %w[Reading Technology Theater]
  r.dislikes  = %w[Bright Lights]
end

event = user.events.find_or_create_by!(name: "Beer oclock") do |e|
  e.event_date = Date.today + 4
  e.event_time = Time.zone.parse("22:00")
  e.location   = "Downtown"
  e.budget     = 50
end


[ recipient1, recipient2 ].each do |rec|
  event.recipients << rec unless event.recipients.exists?(rec.id)
end
