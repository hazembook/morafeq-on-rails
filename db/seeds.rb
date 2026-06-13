# frozen_string_literal: true

# Idempotent seed for records required in every environment.
# Run with: bin/rails db:seed (or runs automatically via db:prepare).
#
# For development/demo data, run: bin/rails demo:seed

admin_email = "admin@morafeq.edu"

unless User.exists?(email_address: admin_email)
  password = SecureRandom.hex(32)

  User.create!(
    full_name: "Admin User",
    email_address: admin_email,
    password: password,
    role: :admin
  )

  puts "  Created admin: #{admin_email} / #{password}"
end
