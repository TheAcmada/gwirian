if Rails.env.production?
  puts "Seeding is disabled in production."
  exit
end

# Ensure admin@example.com user exists
admin_user = User.find_or_create_by!(email_address: 'admin@example.com') do |user|
  user.password = 'Password1234!'
end
