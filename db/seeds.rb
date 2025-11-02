if Rails.env.production?
  puts "Seeding is disabled in production."
  exit
end

# Clean up existing data
Session.delete_all
TestStep.delete_all
TestCase.delete_all
ProjectMember.delete_all
Project.delete_all
LoginHistory.delete_all
User.delete_all

# Ensure admin@example.com user exists
admin_user = User.find_or_create_by!(email_address: 'admin@example.com') do |user|
  user.password = 'Password1234!'
end

puts "Creating projects and test cases..."

# Project 1: E-Commerce Platform
project1 = Project.find_or_create_by!(name: "E-Commerce Platform") do |p|
  p.description = "Main e-commerce application with shopping cart, checkout, and payment processing features."
end

# Add admin as project administrator
ProjectMember.find_or_create_by!(project: project1, email: admin_user.email_address) do |pm|
  pm.role = "administrator"
  pm.invitation_accepted = true
end

# Test Case 1: User Registration
tc1_1 = TestCase.find_or_create_by!(project: project1, title: "User Registration Flow") do |tc|
  tc.description = "Verify that new users can successfully register an account with valid information."
  tc.preconditions = "User is on the registration page and has not previously registered with this email."
  tc.expected_result = "User account is created successfully, verification email is sent, and user is redirected to dashboard."
  tc.priority = :high
  tc.status = :active
  tc.category = "Authentication"
end
tc1_1.tag_list = "critical-path, authentication, signup"
tc1_1.save!

TestStep.find_or_create_by!(test_case: tc1_1, position: 1) do |ts|
  ts.action = "Navigate to the registration page"
  ts.expected_result = "Registration form is displayed"
end
TestStep.find_or_create_by!(test_case: tc1_1, position: 2) do |ts|
  ts.action = "Enter valid email address: test@example.com"
  ts.expected_result = "Email field accepts the input"
end
TestStep.find_or_create_by!(test_case: tc1_1, position: 3) do |ts|
  ts.action = "Enter password with at least 12 characters"
  ts.expected_result = "Password field accepts the input"
end
TestStep.find_or_create_by!(test_case: tc1_1, position: 4) do |ts|
  ts.action = "Click the 'Register' button"
  ts.expected_result = "User is registered and redirected to verification page"
end

# Test Case 2: Add to Cart
tc1_2 = TestCase.find_or_create_by!(project: project1, title: "Add Product to Shopping Cart") do |tc|
  tc.description = "Verify that users can add products to their shopping cart."
  tc.preconditions = "User is logged in and viewing a product detail page."
  tc.expected_result = "Product is added to cart, cart count updates, and user can view cart contents."
  tc.priority = :critical
  tc.status = :active
  tc.category = "Shopping Cart"
end
tc1_2.tag_list = "critical-path, cart, e-commerce"
tc1_2.save!

TestStep.find_or_create_by!(test_case: tc1_2, position: 1) do |ts|
  ts.action = "Navigate to product catalog"
  ts.expected_result = "Product list is displayed"
end
TestStep.find_or_create_by!(test_case: tc1_2, position: 2) do |ts|
  ts.action = "Click on a product to view details"
  ts.expected_result = "Product detail page is displayed"
end
TestStep.find_or_create_by!(test_case: tc1_2, position: 3) do |ts|
  ts.action = "Select quantity: 2"
  ts.expected_result = "Quantity field updates to 2"
end
TestStep.find_or_create_by!(test_case: tc1_2, position: 4) do |ts|
  ts.action = "Click 'Add to Cart' button"
  ts.expected_result = "Product is added to cart, cart icon shows 2 items"
end

# Test Case 3: Checkout Process
tc1_3 = TestCase.find_or_create_by!(project: project1, title: "Complete Checkout Process") do |tc|
  tc.description = "Verify the end-to-end checkout process including payment."
  tc.preconditions = "User is logged in and has at least one item in the shopping cart."
  tc.expected_result = "Order is placed successfully, payment is processed, and order confirmation is displayed."
  tc.priority = :critical
  tc.status = :active
  tc.category = "Checkout"
end
tc1_3.tag_list = "critical-path, checkout, payment"
tc1_3.save!

TestStep.find_or_create_by!(test_case: tc1_3, position: 1) do |ts|
  ts.action = "Click 'Checkout' button from cart page"
  ts.expected_result = "Checkout page is displayed with order summary"
end
TestStep.find_or_create_by!(test_case: tc1_3, position: 2) do |ts|
  ts.action = "Enter shipping address information"
  ts.expected_result = "Shipping form accepts the input"
end
TestStep.find_or_create_by!(test_case: tc1_3, position: 3) do |ts|
  ts.action = "Select shipping method: Standard Shipping"
  ts.expected_result = "Shipping method is selected and total is updated"
end
TestStep.find_or_create_by!(test_case: tc1_3, position: 4) do |ts|
  ts.action = "Enter payment card details"
  ts.expected_result = "Payment form accepts the input"
end
TestStep.find_or_create_by!(test_case: tc1_3, position: 5) do |ts|
  ts.action = "Click 'Place Order' button"
  ts.expected_result = "Order confirmation page is displayed with order number"
end

# Test Case 4: Product Search
tc1_4 = TestCase.find_or_create_by!(project: project1, title: "Search for Products") do |tc|
  tc.description = "Verify that users can search for products using the search functionality."
  tc.preconditions = "User is on the homepage or any page with search functionality."
  tc.expected_result = "Search results are displayed matching the search query."
  tc.priority = :medium
  tc.status = :active
  tc.category = "Search"
end
tc1_4.tag_list = "search, functionality"
tc1_4.save!

TestStep.find_or_create_by!(test_case: tc1_4, position: 1) do |ts|
  ts.action = "Enter search query: 'laptop' in the search box"
  ts.expected_result = "Search box accepts the input"
end
TestStep.find_or_create_by!(test_case: tc1_4, position: 2) do |ts|
  ts.action = "Press Enter or click search icon"
  ts.expected_result = "Search results page displays products matching 'laptop'"
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

# Test Case 1: Create Article
tc2_1 = TestCase.find_or_create_by!(project: project2, title: "Create New Article") do |tc|
  tc.description = "Verify that editors can create new articles with title, content, and metadata."
  tc.preconditions = "User is logged in with editor role and is on the articles dashboard."
  tc.expected_result = "New article is created successfully and appears in the articles list."
  tc.priority = :high
  tc.status = :active
  tc.category = "Content Creation"
end
tc2_1.tag_list = "editor, content, article"
tc2_1.save!

TestStep.find_or_create_by!(test_case: tc2_1, position: 1) do |ts|
  ts.action = "Click 'New Article' button"
  ts.expected_result = "Article creation form is displayed"
end
TestStep.find_or_create_by!(test_case: tc2_1, position: 2) do |ts|
  ts.action = "Enter article title: 'Getting Started with Rails'"
  ts.expected_result = "Title field accepts the input"
end
TestStep.find_or_create_by!(test_case: tc2_1, position: 3) do |ts|
  ts.action = "Enter article content in the editor"
  ts.expected_result = "Content editor accepts the input"
end
TestStep.find_or_create_by!(test_case: tc2_1, position: 4) do |ts|
  ts.action = "Select category: 'Technology'"
  ts.expected_result = "Category is selected"
end
TestStep.find_or_create_by!(test_case: tc2_1, position: 5) do |ts|
  ts.action = "Click 'Publish' button"
  ts.expected_result = "Article is saved and published successfully"
end

# Test Case 2: Upload Media File
tc2_2 = TestCase.find_or_create_by!(project: project2, title: "Upload Media File") do |tc|
  tc.description = "Verify that users can upload images and other media files to the media library."
  tc.preconditions = "User is logged in with editor or administrator role and is on the media library page."
  tc.expected_result = "Media file is uploaded successfully and appears in the media library."
  tc.priority = :medium
  tc.status = :active
  tc.category = "Media Management"
end
tc2_2.tag_list = "upload, media, file"
tc2_2.save!

TestStep.find_or_create_by!(test_case: tc2_2, position: 1) do |ts|
  ts.action = "Click 'Upload Media' button"
  ts.expected_result = "File upload dialog is displayed"
end
TestStep.find_or_create_by!(test_case: tc2_2, position: 2) do |ts|
  ts.action = "Select an image file (jpg, png, or gif)"
  ts.expected_result = "File is selected and preview is shown"
end
TestStep.find_or_create_by!(test_case: tc2_2, position: 3) do |ts|
  ts.action = "Enter alt text: 'Product showcase image'"
  ts.expected_result = "Alt text field accepts the input"
end
TestStep.find_or_create_by!(test_case: tc2_2, position: 4) do |ts|
  ts.action = "Click 'Upload' button"
  ts.expected_result = "File uploads successfully and appears in media library"
end

# Test Case 3: Edit Published Article
tc2_3 = TestCase.find_or_create_by!(project: project2, title: "Edit Published Article") do |tc|
  tc.description = "Verify that editors can edit already published articles."
  tc.preconditions = "At least one published article exists in the system."
  tc.expected_result = "Article is updated and changes are reflected immediately."
  tc.priority = :high
  tc.status = :active
  tc.category = "Content Editing"
end
tc2_3.tag_list = "editor, content, edit"
tc2_3.save!

TestStep.find_or_create_by!(test_case: tc2_3, position: 1) do |ts|
  ts.action = "Navigate to articles list"
  ts.expected_result = "List of articles is displayed"
end
TestStep.find_or_create_by!(test_case: tc2_3, position: 2) do |ts|
  ts.action = "Click 'Edit' on a published article"
  ts.expected_result = "Article edit form is displayed with existing content"
end
TestStep.find_or_create_by!(test_case: tc2_3, position: 3) do |ts|
  ts.action = "Update the article content"
  ts.expected_result = "Content editor updates the text"
end
TestStep.find_or_create_by!(test_case: tc2_3, position: 4) do |ts|
  ts.action = "Click 'Save Changes' button"
  ts.expected_result = "Article is updated successfully"
end

# Test Case 4: Role-Based Access Control
tc2_4 = TestCase.find_or_create_by!(project: project2, title: "Viewer Cannot Edit Content") do |tc|
  tc.description = "Verify that users with viewer role cannot edit or delete content."
  tc.preconditions = "User is logged in with viewer role."
  tc.expected_result = "Edit and delete buttons are not visible to the viewer."
  tc.priority = :high
  tc.status = :active
  tc.category = "Security"
end
tc2_4.tag_list = "security, rbac, permissions"
tc2_4.save!

TestStep.find_or_create_by!(test_case: tc2_4, position: 1) do |ts|
  ts.action = "Navigate to articles list as viewer"
  ts.expected_result = "Articles list is displayed in read-only mode"
end
TestStep.find_or_create_by!(test_case: tc2_4, position: 2) do |ts|
  ts.action = "Verify that 'Edit' and 'Delete' buttons are not visible"
  ts.expected_result = "No edit or delete buttons are displayed"
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

# Test Case 1: Account Login
tc3_1 = TestCase.find_or_create_by!(project: project3, title: "User Login with Biometric Authentication") do |tc|
  tc.description = "Verify that users can log in using biometric authentication (Face ID or Touch ID)."
  tc.preconditions = "User has previously enabled biometric authentication and device supports it."
  tc.expected_result = "User is authenticated and logged into the app successfully."
  tc.priority = :critical
  tc.status = :active
  tc.category = "Authentication"
end
tc3_1.tag_list = "mobile, authentication, biometric, critical-path"
tc3_1.save!

TestStep.find_or_create_by!(test_case: tc3_1, position: 1) do |ts|
  ts.action = "Open the mobile banking app"
  ts.expected_result = "Login screen or biometric prompt is displayed"
end
TestStep.find_or_create_by!(test_case: tc3_1, position: 2) do |ts|
  ts.action = "Authenticate using Face ID or Touch ID"
  ts.expected_result = "Biometric authentication is successful"
end
TestStep.find_or_create_by!(test_case: tc3_1, position: 3) do |ts|
  ts.action = "Verify user is logged in"
  ts.expected_result = "User dashboard is displayed"
end

# Test Case 2: Transfer Funds
tc3_2 = TestCase.find_or_create_by!(project: project3, title: "Transfer Funds Between Accounts") do |tc|
  tc.description = "Verify that users can transfer funds from one account to another."
  tc.preconditions = "User is logged in and has at least two accounts with sufficient balance in the source account."
  tc.expected_result = "Transfer is completed successfully, balance is updated, and confirmation is shown."
  tc.priority = :critical
  tc.status = :active
  tc.category = "Transfers"
end
tc3_2.tag_list = "mobile, transfer, critical-path, payment"
tc3_2.save!

TestStep.find_or_create_by!(test_case: tc3_2, position: 1) do |ts|
  ts.action = "Navigate to 'Transfers' section"
  ts.expected_result = "Transfer screen is displayed"
end
TestStep.find_or_create_by!(test_case: tc3_2, position: 2) do |ts|
  ts.action = "Select source account: Checking Account"
  ts.expected_result = "Source account is selected"
end
TestStep.find_or_create_by!(test_case: tc3_2, position: 3) do |ts|
  ts.action = "Select destination account: Savings Account"
  ts.expected_result = "Destination account is selected"
end
TestStep.find_or_create_by!(test_case: tc3_2, position: 4) do |ts|
  ts.action = "Enter transfer amount: $500.00"
  ts.expected_result = "Amount field accepts the input"
end
TestStep.find_or_create_by!(test_case: tc3_2, position: 5) do |ts|
  ts.action = "Enter optional memo: 'Monthly savings'"
  ts.expected_result = "Memo field accepts the input"
end
TestStep.find_or_create_by!(test_case: tc3_2, position: 6) do |ts|
  ts.action = "Confirm transfer with PIN or biometric"
  ts.expected_result = "Transfer is processed and confirmation screen is displayed"
end

# Test Case 3: View Account Balance
tc3_3 = TestCase.find_or_create_by!(project: project3, title: "View Account Balance") do |tc|
  tc.description = "Verify that users can view their account balances on the dashboard."
  tc.preconditions = "User is logged in and has at least one account."
  tc.expected_result = "Account balances are displayed accurately on the dashboard."
  tc.priority = :high
  tc.status = :active
  tc.category = "Account Information"
end
tc3_3.tag_list = "mobile, dashboard, balance"
tc3_3.save!

TestStep.find_or_create_by!(test_case: tc3_3, position: 1) do |ts|
  ts.action = "Navigate to dashboard/home screen"
  ts.expected_result = "Dashboard is displayed with account overview"
end
TestStep.find_or_create_by!(test_case: tc3_3, position: 2) do |ts|
  ts.action = "Verify account balances are visible"
  ts.expected_result = "All account balances are displayed correctly"
end

# Test Case 4: Bill Payment
tc3_4 = TestCase.find_or_create_by!(project: project3, title: "Pay Utility Bill") do |tc|
  tc.description = "Verify that users can pay utility bills through the app."
  tc.preconditions = "User is logged in, has a payee set up, and sufficient balance."
  tc.expected_result = "Bill payment is scheduled and confirmation is displayed."
  tc.priority = :high
  tc.status = :active
  tc.category = "Bill Payment"
end
tc3_4.tag_list = "mobile, bill-payment, payment"
tc3_4.save!

TestStep.find_or_create_by!(test_case: tc3_4, position: 1) do |ts|
  ts.action = "Navigate to 'Bill Pay' section"
  ts.expected_result = "Bill pay screen is displayed"
end
TestStep.find_or_create_by!(test_case: tc3_4, position: 2) do |ts|
  ts.action = "Select payee: 'Electric Company'"
  ts.expected_result = "Payee is selected"
end
TestStep.find_or_create_by!(test_case: tc3_4, position: 3) do |ts|
  ts.action = "Enter bill amount: $150.00"
  ts.expected_result = "Amount field accepts the input"
end
TestStep.find_or_create_by!(test_case: tc3_4, position: 4) do |ts|
  ts.action = "Select payment date: Today"
  ts.expected_result = "Payment date is selected"
end
TestStep.find_or_create_by!(test_case: tc3_4, position: 5) do |ts|
  ts.action = "Confirm payment"
  ts.expected_result = "Payment is scheduled and confirmation is displayed"
end

# Test Case 5: Transaction History
tc3_5 = TestCase.find_or_create_by!(project: project3, title: "View Transaction History") do |tc|
  tc.description = "Verify that users can view their transaction history with filters."
  tc.preconditions = "User is logged in and has transaction history."
  tc.expected_result = "Transaction history is displayed with ability to filter by date range and transaction type."
  tc.priority = :medium
  tc.status = :active
  tc.category = "Account Information"
end
tc3_5.tag_list = "mobile, transactions, history"
tc3_5.save!

TestStep.find_or_create_by!(test_case: tc3_5, position: 1) do |ts|
  ts.action = "Navigate to 'Transactions' section"
  ts.expected_result = "Transaction history is displayed"
end
TestStep.find_or_create_by!(test_case: tc3_5, position: 2) do |ts|
  ts.action = "Select date range: Last 30 days"
  ts.expected_result = "Transactions are filtered to show last 30 days"
end
TestStep.find_or_create_by!(test_case: tc3_5, position: 3) do |ts|
  ts.action = "Filter by transaction type: 'Debits'"
  ts.expected_result = "Only debit transactions are displayed"
end

puts "Seeding complete! Created:"
puts "  - #{Project.count} projects"
puts "  - #{TestCase.count} test cases"
puts "  - #{TestStep.count} test steps"
