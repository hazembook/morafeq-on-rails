# Comprehensive seed data for development/demo
# Run with: bin/rails db:seed
#
# NOTE: Academic models (College, Department, Subject, Enrollment) seeds
# will be added in Phase 2 when those models are created.

puts "Cleaning existing users..."
User.delete_all

puts "Creating users..."

User.create!(
  full_name: "Admin User",
  email_address: "admin@morafeq.edu",
  password: "password123",
  role: :admin
)

User.create!(
  full_name: "Dr. Ahmed Hassan",
  email_address: "ahmed@morafeq.edu",
  password: "password123",
  role: :teacher
)

User.create!(
  full_name: "Dr. Sara Ali",
  email_address: "sara@morafeq.edu",
  password: "password123",
  role: :teacher
)

User.create!(
  full_name: "Dr. Khaled Omar",
  email_address: "khaled@morafeq.edu",
  password: "password123",
  role: :teacher
)

User.create!(
  full_name: "Omar Youssef",
  email_address: "omar@morafeq.edu",
  password: "password123",
  role: :student
)

User.create!(
  full_name: "Layla Mahmoud",
  email_address: "layla@morafeq.edu",
  password: "password123",
  role: :student
)

User.create!(
  full_name: "Yassin Nour",
  email_address: "yassin@morafeq.edu",
  password: "password123",
  role: :student
)

User.create!(
  full_name: "Nadia Ibrahim",
  email_address: "nadia@morafeq.edu",
  password: "password123",
  role: :student
)

puts "Seeding complete!"
puts "  #{User.count} users created:"
User.group(:role).count.each do |role, count|
  puts "    #{role}: #{count}"
end
