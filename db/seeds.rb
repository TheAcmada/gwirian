if Rails.env.production?
  puts "Seeding is disabled in production."
  exit
end

# Clean up existing data
Session.delete_all
Feature.delete_all
ProjectMember.delete_all
Project.delete_all
LoginHistory.delete_all
User.delete_all

# Ensure admin@example.com user exists
admin_user = User.find_or_create_by!(email_address: 'admin@example.com') do |user|
  user.password = 'Password1234!'
end

puts "Creating projects..."

# Project 1: E-Commerce Platform
project1 = Project.find_or_create_by!(name: "E-Commerce Platform") do |p|
  p.description = "Main e-commerce application with shopping cart, checkout, and payment processing features."
end

# Add admin as project administrator
ProjectMember.find_or_create_by!(project: project1, email: admin_user.email_address) do |pm|
  pm.role = "administrator"
  pm.invitation_accepted = true
end

# Project 2: Content Management System
project2 = Project.find_or_create_by!(name: "Content Management System") do |p|
  p.description = "CMS platform for managing articles, pages, and media content with role-based access control."
end

# Add admin as project administrator
ProjectMember.find_or_create_by!(project: project2, email: admin_user.email_address) do |pm|
  pm.role = "administrator"
  pm.invitation_accepted = true
end

# Project 3: Mobile Banking App
project3 = Project.find_or_create_by!(name: "Mobile Banking Application") do |p|
  p.description = "Mobile banking app for iOS and Android with features for account management, transfers, and bill payments."
end

# Add admin as project administrator
ProjectMember.find_or_create_by!(project: project3, email: admin_user.email_address) do |pm|
  pm.role = "administrator"
  pm.invitation_accepted = true
end

puts "Creating features..."

# Features for E-Commerce Platform
Feature.find_or_create_by!(project: project1, title: "Shopping Cart") do |f|
  f.description = "Users can add products to their cart and manage quantities before checkout."
end

Feature.find_or_create_by!(project: project1, title: "Payment Processing") do |f|
  f.description = "Secure payment processing with support for credit cards, PayPal, and other payment methods."
end

Feature.find_or_create_by!(project: project1, title: "Product Search") do |f|
  f.description = "Advanced search functionality with filters for category, price range, and ratings."
end

# Features for Content Management System
Feature.find_or_create_by!(project: project2, title: "Article Editor") do |f|
  f.description = "Rich text editor for creating and editing articles with support for images, videos, and formatting."
end

Feature.find_or_create_by!(project: project2, title: "Role-Based Access Control") do |f|
  f.description = "Manage user permissions with roles like admin, editor, author, and viewer."
end

Feature.find_or_create_by!(project: project2, title: "Media Library") do |f|
  f.description = "Upload, organize, and manage media files including images, videos, and documents."
end

# Features for Mobile Banking App
Feature.find_or_create_by!(project: project3, title: "Account Balance Display") do |f|
  f.description = "Real-time display of account balances for checking, savings, and investment accounts."
end

Feature.find_or_create_by!(project: project3, title: "Money Transfer") do |f|
  f.description = "Transfer funds between accounts or to external recipients with transaction history."
end

Feature.find_or_create_by!(project: project3, title: "Bill Payment") do |f|
  f.description = "Pay bills directly from the app with support for scheduled and recurring payments."
end

puts "Seeding complete! Created:"
puts "  - #{Project.count} projects"
puts "  - #{Feature.count} features"
