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
  f.background = "the user is logged into the e-commerce platform\n  And products are available in the catalog\n  And the shopping cart persists across sessions"
end

Feature.find_or_create_by!(project: project1, title: "Payment Processing") do |f|
  f.description = "Secure payment processing with support for credit cards, PayPal, and other payment methods."
  f.background = "the user has items in their shopping cart\n  And the user has selected a payment method\n  And the payment gateway is configured and PCI compliant"
end

Feature.find_or_create_by!(project: project1, title: "Product Search") do |f|
  f.description = "Advanced search functionality with filters for category, price range, and ratings."
  f.background = "the user is on the product catalog page\n  And products are indexed and searchable\n  And the search engine supports autocomplete and typo tolerance"
end

# Features for Content Management System
Feature.find_or_create_by!(project: project2, title: "Article Editor") do |f|
  f.description = "Rich text editor for creating and editing articles with support for images, videos, and formatting."
  f.background = "the user has the appropriate permissions to create or edit articles\n  And the editor supports both markdown and WYSIWYG modes\n  And media files are available in the media library"
end

Feature.find_or_create_by!(project: project2, title: "Role-Based Access Control") do |f|
  f.description = "Manage user permissions with roles like admin, editor, author, and viewer."
  f.background = "users exist in the system\n  And roles are defined (admin, editor, author, viewer)\n  And permissions are assigned based on roles"
end

Feature.find_or_create_by!(project: project2, title: "Media Library") do |f|
  f.description = "Upload, organize, and manage media files including images, videos, and documents."
  f.background = "the user has permission to access the media library\n  And storage is configured for media files\n  And the library supports drag-and-drop uploads and folder organization"
end

# Features for Mobile Banking App
Feature.find_or_create_by!(project: project3, title: "Account Balance Display") do |f|
  f.description = "Real-time display of account balances for checking, savings, and investment accounts."
  f.background = "the user is authenticated in the mobile banking app\n  And the user has linked accounts (checking, savings, investment)\n  And account data is available in real-time"
end

Feature.find_or_create_by!(project: project3, title: "Money Transfer") do |f|
  f.description = "Transfer funds between accounts or to external recipients with transaction history."
  f.background = "the user is authenticated and has sufficient funds\n  And transfer verification is enabled\n  And the user can save frequent recipients"
end

Feature.find_or_create_by!(project: project3, title: "Bill Payment") do |f|
  f.description = "Pay bills directly from the app with support for scheduled and recurring payments."
  f.background = "the user is authenticated\n  And billers can be added to the system\n  And payment scheduling is enabled"
end

puts "Seeding complete! Created:"
puts "  - #{Project.count} projects"
puts "  - #{Feature.count} features"
