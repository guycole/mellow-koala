# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

[
  { component_id: "mellow-heeler",  display_name: "Mellow Heeler",  description: "Reports WiFi AP beacon observations" },
  { component_id: "mellow-hyena",   display_name: "Mellow Hyena",   description: "Mellow Hyena component" },
  { component_id: "mellow-mastodon", display_name: "Mellow Mastodon", description: "Mellow Mastodon component" },
  { component_id: "mellow-manatee", display_name: "Mellow Manatee", description: "Mellow Manatee component" }
].each do |attrs|
  component = Component.find_or_initialize_by(component_id: attrs[:component_id])
  component.display_name = attrs[:display_name]
  component.description  = attrs[:description]
  # Only set a token on create so existing tokens are not rotated by re-seeding
  if component.new_record?
    raw_token = SecureRandom.hex(32)
    component.ingest_token = raw_token
    component.save!
    puts "Created #{attrs[:display_name]} — ingest token: #{raw_token}"
  else
    component.save!
    puts "Updated #{attrs[:display_name]} (token unchanged)"
  end
end
