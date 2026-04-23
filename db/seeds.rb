# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

[
  { collector_id: "mellow-heeler",     display_name: "Mellow Heeler",     description: "Reports WiFi AP beacon observations",               collection_only: true },
  { collector_id: "mellow-hyena-adsb", display_name: "Mellow Hyena-ADSB", description: "Reports ADSB aviation beacon observations",          collection_only: true },
  { collector_id: "mellow-hyena-uat",  display_name: "Mellow Hyena-UAT",  description: "Reports UAT aviation beacon observations",           collection_only: true },
  { collector_id: "mellow-mastodon",   display_name: "Mellow Mastodon",   description: "Reports energy survey peaker observations",          collection_only: true },
  { collector_id: "mellow-manatee",    display_name: "Mellow Manatee",    description: "Reports Mellow Manatee observations",               collection_only: false }
].each do |attrs|
  collector = Collector.find_or_initialize_by(collector_id: attrs[:collector_id])
  collector.display_name    = attrs[:display_name]
  collector.description     = attrs[:description]
  collector.collection_only = attrs[:collection_only]
  # Only set a token on create so existing tokens are not rotated by re-seeding
  if collector.new_record?
    raw_token = SecureRandom.hex(32)
    collector.ingest_token = raw_token
    collector.save!
    puts "Created #{attrs[:display_name]} — ingest token: #{raw_token}"
  else
    collector.save!
    puts "Updated #{attrs[:display_name]} (token unchanged)"
  end
end
