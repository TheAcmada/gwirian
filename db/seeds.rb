if Rails.env.production?
  puts "Seeding is disabled in production."
  exit
end

# Clean up existing data
Session.delete_all
Scenario.delete_all
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
end

# Project 2: Content Management System
project2 = Project.find_or_create_by!(name: "Content Management System") do |p|
  p.description = "CMS platform for managing articles, pages, and media content with role-based access control."
end

# Add admin as project administrator
ProjectMember.find_or_create_by!(project: project2, email: admin_user.email_address) do |pm|
  pm.role = "administrator"
end

# Project 3: Mobile Banking App
project3 = Project.find_or_create_by!(name: "Mobile Banking Application") do |p|
  p.description = "Mobile banking app for iOS and Android with features for account management, transfers, and bill payments."
end

# Add admin as project administrator
ProjectMember.find_or_create_by!(project: project3, email: admin_user.email_address) do |pm|
  pm.role = "administrator"
end

puts "Creating features..."

# Features for E-Commerce Platform
f1_1 = Feature.find_or_create_by!(project: project1, title: "Shopping Cart") do |f|
  f.description = "Users can add products to their cart and manage quantities before checkout."
end
f1_1.tag_list = "critical-path, cart, checkout, e-commerce"
f1_1.save!

f1_2 = Feature.find_or_create_by!(project: project1, title: "Payment Processing") do |f|
  f.description = "Secure payment processing with support for credit cards, PayPal, and other payment methods."
end
f1_2.tag_list = "critical-path, payment, security, checkout"
f1_2.save!

f1_3 = Feature.find_or_create_by!(project: project1, title: "Product Search") do |f|
  f.description = "Advanced search functionality with filters for category, price range, and ratings."
end
f1_3.tag_list = "search, functionality, user-experience"
f1_3.save!

f1_4 = Feature.find_or_create_by!(project: project1, title: "Order Tracking") do |f|
  f.description = "Real-time order tracking with status updates and delivery notifications for customers."
end
f1_4.tag_list = "tracking, notifications, customer-service"
f1_4.save!

f1_5 = Feature.find_or_create_by!(project: project1, title: "Product Reviews") do |f|
  f.description = "Customer review system with ratings, photos, and verified purchase badges."
end
f1_5.tag_list = "reviews, social-proof, user-generated-content"
f1_5.save!

# Features for Content Management System
f2_1 = Feature.find_or_create_by!(project: project2, title: "Article Editor") do |f|
  f.description = "Rich text editor for creating and editing articles with support for images, videos, and formatting."
end
f2_1.tag_list = "editor, content-creation, wysiwyg"
f2_1.save!

f2_2 = Feature.find_or_create_by!(project: project2, title: "Role-Based Access Control") do |f|
  f.description = "Manage user permissions with roles like admin, editor, author, and viewer."
end
f2_2.tag_list = "security, rbac, permissions, access-control"
f2_2.save!

f2_3 = Feature.find_or_create_by!(project: project2, title: "Media Library") do |f|
  f.description = "Upload, organize, and manage media files including images, videos, and documents."
end
f2_3.tag_list = "upload, media, file-management"
f2_3.save!

f2_4 = Feature.find_or_create_by!(project: project2, title: "Content Scheduling") do |f|
  f.description = "Schedule articles and pages to be published at specific dates and times."
end
f2_4.tag_list = "scheduling, automation, publishing"
f2_4.save!

f2_5 = Feature.find_or_create_by!(project: project2, title: "SEO Management") do |f|
  f.description = "Built-in SEO tools for meta tags, descriptions, and URL optimization."
end
f2_5.tag_list = "seo, optimization, marketing"
f2_5.save!

# Features for Mobile Banking App
f3_1 = Feature.find_or_create_by!(project: project3, title: "Account Balance Display") do |f|
  f.description = "Real-time display of account balances for checking, savings, and investment accounts."
end
f3_1.tag_list = "mobile, dashboard, account-information, critical-path"
f3_1.save!

f3_2 = Feature.find_or_create_by!(project: project3, title: "Money Transfer") do |f|
  f.description = "Transfer funds between accounts or to external recipients with transaction history."
end
f3_2.tag_list = "mobile, transfer, critical-path, payment"
f3_2.save!

f3_3 = Feature.find_or_create_by!(project: project3, title: "Bill Payment") do |f|
  f.description = "Pay bills directly from the app with support for scheduled and recurring payments."
end
f3_3.tag_list = "mobile, bill-payment, payment, automation"
f3_3.save!

f3_4 = Feature.find_or_create_by!(project: project3, title: "Transaction History") do |f|
  f.description = "Comprehensive transaction history with search, filters, and export functionality."
end
f3_4.tag_list = "mobile, transactions, history, reporting"
f3_4.save!

# Project 4: Task Management System
project4 = Project.find_or_create_by!(name: "Task Management System") do |p|
  p.description = "Collaborative task management platform with project tracking, team collaboration, and productivity tools."
end

# Add admin as project administrator
ProjectMember.find_or_create_by!(project: project4, email: admin_user.email_address) do |pm|
  pm.role = "administrator"
end

# Features for Task Management System
f4_1 = Feature.find_or_create_by!(project: project4, title: "Task Creation") do |f|
  f.description = "Create and assign tasks with due dates, priorities, and detailed descriptions."
end
f4_1.tag_list = "task-management, core-feature, productivity"
f4_1.save!

f4_2 = Feature.find_or_create_by!(project: project4, title: "Project Boards") do |f|
  f.description = "Kanban-style boards for visualizing task progress across different stages."
end
f4_2.tag_list = "kanban, visualization, project-management"
f4_2.save!

f4_3 = Feature.find_or_create_by!(project: project4, title: "Team Collaboration") do |f|
  f.description = "Real-time collaboration with comments, mentions, and activity feeds."
end
f4_3.tag_list = "collaboration, communication, real-time"
f4_3.save!

f4_4 = Feature.find_or_create_by!(project: project4, title: "Time Tracking") do |f|
  f.description = "Track time spent on tasks with detailed reports and analytics."
end
f4_4.tag_list = "time-tracking, reporting, analytics"
f4_4.save!

puts "Creating scenarios..."

# Scenarios for Shopping Cart (f1_1)
Scenario.find_or_create_by!(feature: f1_1, title: "Add item to empty cart") do |s|
  s.given = "the user is viewing a product page and the cart is empty"
  s.when = "the user clicks the 'Add to Cart' button"
  s.then = "the product is added to the cart and the cart badge shows 1 item"
end

Scenario.find_or_create_by!(feature: f1_1, title: "Update item quantity") do |s|
  s.given = "the user has items in the cart"
  s.when = "the user changes the quantity of an item"
  s.then = "the cart total is recalculated and displayed"
end

Scenario.find_or_create_by!(feature: f1_1, title: "Remove item from cart") do |s|
  s.given = "the user has multiple items in the cart"
  s.when = "the user clicks the remove button on an item"
  s.then = "the item is removed and the cart total updates"
end

# Scenarios for Payment Processing (f1_2)
Scenario.find_or_create_by!(feature: f1_2, title: "Successful credit card payment") do |s|
  s.given = "the user has items in the cart and is on the checkout page"
  s.when = "the user enters valid credit card details and clicks 'Pay'"
  s.then = "the payment is processed and the order confirmation is displayed"
end

Scenario.find_or_create_by!(feature: f1_2, title: "Payment declined") do |s|
  s.given = "the user is on the checkout page"
  s.when = "the user enters an invalid credit card number"
  s.then = "an error message is displayed and the user can retry"
end

# Scenarios for Product Search (f1_3)
Scenario.find_or_create_by!(feature: f1_3, title: "Search by keyword") do |s|
  s.given = "the user is on the homepage"
  s.when = "the user enters 'laptop' in the search bar and presses Enter"
  s.then = "a list of matching products is displayed"
end

Scenario.find_or_create_by!(feature: f1_3, title: "Filter search results") do |s|
  s.given = "the user has search results displayed"
  s.when = "the user applies a price filter of $500-$1000"
  s.then = "only products within that price range are shown"
end

# Scenarios for Article Editor (f2_1)
Scenario.find_or_create_by!(feature: f2_1, title: "Create new article") do |s|
  s.given = "the user is logged in as an editor"
  s.when = "the user clicks 'New Article' and fills in the title and content"
  s.then = "the article is saved as a draft"
end

Scenario.find_or_create_by!(feature: f2_1, title: "Add image to article") do |s|
  s.given = "the user is editing an article"
  s.when = "the user clicks the image button and selects a file"
  s.then = "the image is uploaded and inserted at the cursor position"
end

# Scenarios for Role-Based Access Control (f2_2)
Scenario.find_or_create_by!(feature: f2_2, title: "Admin assigns editor role") do |s|
  s.given = "an admin is viewing the user management page"
  s.when = "the admin changes a user's role from 'viewer' to 'editor'"
  s.then = "the user gains access to content editing features"
end

Scenario.find_or_create_by!(feature: f2_2, title: "Viewer cannot edit content") do |s|
  s.given = "a user with 'viewer' role is logged in"
  s.when = "the user attempts to access the article editor"
  s.then = "access is denied and a permission error is shown"
end

# Scenarios for Account Balance Display (f3_1)
Scenario.find_or_create_by!(feature: f3_1, title: "View all account balances") do |s|
  s.given = "the user is logged into the mobile app"
  s.when = "the user navigates to the accounts dashboard"
  s.then = "all account balances are displayed with real-time data"
end

Scenario.find_or_create_by!(feature: f3_1, title: "Refresh account balance") do |s|
  s.given = "the user is viewing their account balance"
  s.when = "the user pulls down to refresh"
  s.then = "the latest balance is fetched and displayed"
end

# Scenarios for Money Transfer (f3_2)
Scenario.find_or_create_by!(feature: f3_2, title: "Transfer between own accounts") do |s|
  s.given = "the user has multiple accounts with sufficient funds"
  s.when = "the user initiates a transfer of $100 from checking to savings"
  s.then = "the transfer is completed and both balances are updated"
end

Scenario.find_or_create_by!(feature: f3_2, title: "Transfer to external recipient") do |s|
  s.given = "the user has a saved recipient"
  s.when = "the user sends $50 to the saved recipient"
  s.then = "the transfer is queued and a confirmation is shown"
end

# Scenarios for Task Creation (f4_1)
Scenario.find_or_create_by!(feature: f4_1, title: "Create task with due date") do |s|
  s.given = "the user is on a project board"
  s.when = "the user creates a new task with title, description, and due date"
  s.then = "the task appears in the backlog column"
end

Scenario.find_or_create_by!(feature: f4_1, title: "Assign task to team member") do |s|
  s.given = "a task exists without an assignee"
  s.when = "the user assigns the task to a team member"
  s.then = "the assignee receives a notification and the task shows their avatar"
end

# Scenarios for Project Boards (f4_2)
Scenario.find_or_create_by!(feature: f4_2, title: "Move task between columns") do |s|
  s.given = "a task is in the 'To Do' column"
  s.when = "the user drags the task to 'In Progress'"
  s.then = "the task status is updated and it appears in the new column"
end

Scenario.find_or_create_by!(feature: f4_2, title: "Create custom column") do |s|
  s.given = "the user is viewing a project board"
  s.when = "the user adds a new column called 'Code Review'"
  s.then = "the column appears on the board and tasks can be moved to it"
end

# Some scenarios with empty Given/When/Then to test placeholders
Scenario.find_or_create_by!(feature: f4_3, title: "Comment on a task") do |s|
  s.given = ""
  s.when = ""
  s.then = ""
end

Scenario.find_or_create_by!(feature: f4_4, title: "Start time tracking") do |s|
  s.given = "the user is viewing a task"
  s.when = ""
  s.then = ""
end

puts "Seeding complete! Created:"
puts "  - #{Project.count} projects"
puts "  - #{Feature.count} features"
puts "  - #{Scenario.count} scenarios"
