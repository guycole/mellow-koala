# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.

# Default admin user
User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password = "password123"
end

puts "Seeded admin user: admin@example.com / password123"

