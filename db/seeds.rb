# frozen_string_literal: true

if Rails.env.production?
  puts "Seeding is disabled in production."
  exit
end

# Order required for foreign key constraints (dependents before parents)
SEED_CLEANUP_ORDER = [
  ScenarioExecution, Step, Scenario, Feature, ProjectMember, Project,
  WorkspaceMember, Session, MagicLink, LoginHistory, User, Workspace
].freeze

def seed_cleanup!
  SEED_CLEANUP_ORDER.each(&:delete_all)
end

def seed_admin_user
  User.find_or_create_by!(email_address: "admin@example.com")
end

def seed_default_workspace(admin_user)
  workspace = Workspace.find_or_create_by!(name: "Default Workspace") do |w|
    w.description = "Default workspace for development and testing."
  end
  WorkspaceMember.find_or_create_by!(workspace: workspace, user: admin_user) do |wm|
    wm.role = "administrator"
    wm.status = "current_member"
  end
  workspace
end

def seed_project(workspace, name:, description:, admin_user:)
  project = Project.find_or_create_by!(workspace: workspace, name: name) do |p|
    p.description = description
  end
  ProjectMember.find_or_create_by!(project: project, email: admin_user.email_address) do |pm|
    pm.role = "administrator"
  end
  project
end

def seed_feature(project, title:, description:, tag_list: nil)
  feature = Feature.find_or_create_by!(project: project, title: title) do |f|
    f.description = description
  end
  if tag_list.present?
    feature.tag_list = tag_list
    feature.save!
  end
  feature
end

def seed_scenario(feature, title:, given: "", when_step: nil, then_step: nil)
  Scenario.find_or_create_by!(feature: feature, title: title) do |s|
    s.given = (given || "").to_s
    s.when = (when_step || "").to_s
    s.then = (then_step || "").to_s
  end
end

# ---------------------------------------------------------------------------
# Seed data: add or edit projects, features, and scenarios here
# ---------------------------------------------------------------------------

PROJECTS_SEED = [
  {
    name: "E-Commerce Platform",
    description: "Main e-commerce application with shopping cart, checkout, and payment processing features.",
    features: [
      { title: "Shopping Cart", description: "Users can add products to their cart and manage quantities before checkout.", tag_list: "critical-path, cart, checkout, e-commerce",
        scenarios: [
          { title: "Add item to empty cart", given: "the user is viewing a product page and the cart is empty", when: "the user clicks the 'Add to Cart' button", then: "the product is added to the cart and the cart badge shows 1 item" },
          { title: "Update item quantity", given: "the user has items in the cart", when: "the user changes the quantity of an item", then: "the cart total is recalculated and displayed" },
          { title: "Remove item from cart", given: "the user has multiple items in the cart", when: "the user clicks the remove button on an item", then: "the item is removed and the cart total updates" },
          { title: "Apply discount code", given: "the user has items in the cart and a valid promo code exists", when: "the user enters the code and applies it", then: "the discount is applied and the cart total reflects the reduced price" },
          { title: "Cart persists across sessions", given: "the user added items to the cart while logged in", when: "the user returns to the site in a new session", then: "the cart still contains the previously added items" }
        ] },
      { title: "Payment Processing", description: "Secure payment processing with support for credit cards, PayPal, and other payment methods.", tag_list: "critical-path, payment, security, checkout",
        scenarios: [
          { title: "Successful credit card payment", given: "the user has items in the cart and is on the checkout page", when: "the user enters valid credit card details and clicks 'Pay'", then: "the payment is processed and the order confirmation is displayed" },
          { title: "Payment declined", given: "the user is on the checkout page", when: "the user enters an invalid credit card number", then: "an error message is displayed and the user can retry" },
          { title: "Pay with PayPal", given: "the user has items in the cart and selected PayPal at checkout", when: "the user completes authentication in the PayPal popup", then: "the payment is processed and the order confirmation is displayed" },
          { title: "Save card for future use", given: "the user is on the checkout page", when: "the user checks 'Save this card' and completes payment", then: "the card is stored and available for future checkouts" }
        ] },
      { title: "Product Search", description: "Advanced search functionality with filters for category, price range, and ratings.", tag_list: "search, functionality, user-experience",
        scenarios: [
          { title: "Search by keyword", given: "the user is on the homepage", when: "the user enters 'laptop' in the search bar and presses Enter", then: "a list of matching products is displayed" },
          { title: "Filter search results", given: "the user has search results displayed", when: "the user applies a price filter of $500-$1000", then: "only products within that price range are shown" },
          { title: "Sort by rating", given: "the user has search results displayed", when: "the user selects 'Sort by rating'", then: "results are reordered with highest-rated products first" },
          { title: "No results for query", given: "the user is on the search page", when: "the user searches for a term with no matching products", then: "a 'no results' message is shown with suggestions or related categories" }
        ] },
      { title: "Order Tracking", description: "Real-time order tracking with status updates and delivery notifications for customers.", tag_list: "tracking, notifications, customer-service",
        scenarios: [
          { title: "View order status", given: "the user has placed an order", when: "the user opens the order details page", then: "the current status and estimated delivery date are displayed" },
          { title: "Receive delivery notification", given: "an order has been shipped", when: "the package is out for delivery", then: "the user receives a notification with tracking link and ETA" },
          { title: "Track shipment on map", given: "the user is viewing a shipped order", when: "the user clicks 'Track package'", then: "a map or timeline shows the current location and delivery progress" }
        ] },
      { title: "Product Reviews", description: "Customer review system with ratings, photos, and verified purchase badges.", tag_list: "reviews, social-proof, user-generated-content",
        scenarios: [
          { title: "Submit review after purchase", given: "the user has received a purchased product", when: "the user goes to the product page and submits a rating with comment", then: "the review is saved and marked as verified purchase" },
          { title: "Filter reviews by rating", given: "the user is viewing a product with many reviews", when: "the user selects '4 stars and up'", then: "only reviews with 4 or 5 stars are displayed" },
          { title: "Upload photo with review", given: "the user is writing a product review", when: "the user attaches one or more photos", then: "the photos are uploaded and appear in the published review" }
        ] }
    ]
  },
  {
    name: "Content Management System",
    description: "CMS platform for managing articles, pages, and media content with role-based access control.",
    features: [
      { title: "Article Editor", description: "Rich text editor for creating and editing articles with support for images, videos, and formatting.", tag_list: "editor, content-creation, wysiwyg",
        scenarios: [
          { title: "Create new article", given: "the user is logged in as an editor", when: "the user clicks 'New Article' and fills in the title and content", then: "the article is saved as a draft" },
          { title: "Add image to article", given: "the user is editing an article", when: "the user clicks the image button and selects a file", then: "the image is uploaded and inserted at the cursor position" },
          { title: "Publish scheduled article", given: "the user has an article saved as draft with a future publish date", when: "the publish date and time are reached", then: "the article is automatically published and visible to readers" },
          { title: "Preview before publish", given: "the user is editing an article", when: "the user clicks 'Preview'", then: "a read-only preview opens in a new tab showing how the article will appear" }
        ] },
      { title: "Role-Based Access Control", description: "Manage user permissions with roles like admin, editor, author, and viewer.", tag_list: "security, rbac, permissions, access-control",
        scenarios: [
          { title: "Admin assigns editor role", given: "an admin is viewing the user management page", when: "the admin changes a user's role from 'viewer' to 'editor'", then: "the user gains access to content editing features" },
          { title: "Viewer cannot edit content", given: "a user with 'viewer' role is logged in", when: "the user attempts to access the article editor", then: "access is denied and a permission error is shown" },
          { title: "Author can edit own content only", given: "a user with 'author' role is logged in", when: "the user tries to edit an article created by another user", then: "access is denied unless they are the author" },
          { title: "Editor can publish any draft", given: "an editor is viewing a draft article by an author", when: "the editor clicks 'Publish'", then: "the article is published and the author is notified" }
        ] },
      { title: "Media Library", description: "Upload, organize, and manage media files including images, videos, and documents.", tag_list: "upload, media, file-management",
        scenarios: [
          { title: "Upload image file", given: "the user is in the Media Library with upload permission", when: "the user selects an image file and clicks Upload", then: "the file is uploaded and appears in the library with thumbnail" },
          { title: "Organize files in folder", given: "the user has multiple files in the Media Library", when: "the user creates a folder and drags files into it", then: "the files are moved and the folder structure is saved" },
          { title: "Search media by filename", given: "the Media Library contains many files", when: "the user types a filename or keyword in the search box", then: "matching files are displayed" }
        ] },
      { title: "Content Scheduling", description: "Schedule articles and pages to be published at specific dates and times.", tag_list: "scheduling, automation, publishing",
        scenarios: [
          { title: "Schedule article for future publish", given: "the user is editing a draft article", when: "the user sets a future date and time and clicks 'Schedule'", then: "the article is scheduled and will auto-publish at that time" },
          { title: "Unschedule scheduled article", given: "an article is scheduled for future publication", when: "the user clicks 'Unschedule'", then: "the article reverts to draft and the publish date is cleared" },
          { title: "View calendar of scheduled content", given: "the user is on the CMS dashboard", when: "the user opens the content calendar", then: "all scheduled articles and pages are shown by date" }
        ] },
      { title: "SEO Management", description: "Built-in SEO tools for meta tags, descriptions, and URL optimization.", tag_list: "seo, optimization, marketing",
        scenarios: [
          { title: "Edit meta title and description", given: "the user is editing a page or article", when: "the user fills in the SEO meta title and description fields", then: "the values are saved and used for search result snippets" },
          { title: "Customize URL slug", given: "the user is creating a new page", when: "the user changes the URL slug from the auto-generated value", then: "the page is accessible at the custom URL" },
          { title: "Preview search result snippet", given: "the user has set meta title and description for a page", when: "the user clicks 'Preview snippet'", then: "a preview of how the page may appear in search results is shown" }
        ] }
    ]
  },
  {
    name: "Mobile Banking Application",
    description: "Mobile banking app for iOS and Android with features for account management, transfers, and bill payments.",
    features: [
      { title: "Account Balance Display", description: "Real-time display of account balances for checking, savings, and investment accounts.", tag_list: "mobile, dashboard, account-information, critical-path",
        scenarios: [
          { title: "View all account balances", given: "the user is logged into the mobile app", when: "the user navigates to the accounts dashboard", then: "all account balances are displayed with real-time data" },
          { title: "Refresh account balance", given: "the user is viewing their account balance", when: "the user pulls down to refresh", then: "the latest balance is fetched and displayed" },
          { title: "Tap account for details", given: "the user is on the accounts dashboard", when: "the user taps on a specific account", then: "the account detail screen opens with balance and recent transactions" }
        ] },
      { title: "Money Transfer", description: "Transfer funds between accounts or to external recipients with transaction history.", tag_list: "mobile, transfer, critical-path, payment",
        scenarios: [
          { title: "Transfer between own accounts", given: "the user has multiple accounts with sufficient funds", when: "the user initiates a transfer of $100 from checking to savings", then: "the transfer is completed and both balances are updated" },
          { title: "Transfer to external recipient", given: "the user has a saved recipient", when: "the user sends $50 to the saved recipient", then: "the transfer is queued and a confirmation is shown" },
          { title: "Transfer amount exceeds balance", given: "the user has $50 in checking", when: "the user attempts to transfer $100 to savings", then: "an error is shown and the transfer is not processed" },
          { title: "Save new recipient", given: "the user is on the transfer screen", when: "the user enters recipient details and selects 'Save for future'", then: "the recipient is saved and appears in the recipient list" }
        ] },
      { title: "Bill Payment", description: "Pay bills directly from the app with support for scheduled and recurring payments.", tag_list: "mobile, bill-payment, payment, automation",
        scenarios: [
          { title: "Pay one-time bill", given: "the user has added a payee and has sufficient funds", when: "the user enters the amount and confirms payment", then: "the payment is processed and appears in transaction history" },
          { title: "Schedule bill for future date", given: "the user is on the bill payment screen", when: "the user selects a future date and submits the payment", then: "the payment is scheduled and will be processed on that date" },
          { title: "Set up recurring payment", given: "the user has a payee saved", when: "the user enables recurring and sets frequency and amount", then: "future payments are automatically scheduled" }
        ] },
      { title: "Transaction History", description: "Comprehensive transaction history with search, filters, and export functionality.", tag_list: "mobile, transactions, history, reporting",
        scenarios: [
          { title: "View transaction list", given: "the user is logged in", when: "the user opens Transaction History", then: "transactions are listed with date, description, and amount" },
          { title: "Filter by date range", given: "the user is viewing transaction history", when: "the user selects 'Last 30 days'", then: "only transactions in that range are shown" },
          { title: "Export transactions", given: "the user has filtered or viewed transactions", when: "the user taps 'Export' and chooses CSV", then: "a file is generated and offered for download or share" }
        ] }
    ]
  },
  {
    name: "Task Management System",
    description: "Collaborative task management platform with project tracking, team collaboration, and productivity tools.",
    features: [
      { title: "Task Creation", description: "Create and assign tasks with due dates, priorities, and detailed descriptions.", tag_list: "task-management, core-feature, productivity",
        scenarios: [
          { title: "Create task with due date", given: "the user is on a project board", when: "the user creates a new task with title, description, and due date", then: "the task appears in the backlog column" },
          { title: "Assign task to team member", given: "a task exists without an assignee", when: "the user assigns the task to a team member", then: "the assignee receives a notification and the task shows their avatar" },
          { title: "Set task priority", given: "the user is creating or editing a task", when: "the user selects 'High' priority", then: "the task is saved with high priority and may be visually highlighted" },
          { title: "Add subtasks", given: "the user is editing a task", when: "the user adds two subtasks with titles", then: "the subtasks appear under the task and progress can be tracked" }
        ] },
      { title: "Project Boards", description: "Kanban-style boards for visualizing task progress across different stages.", tag_list: "kanban, visualization, project-management",
        scenarios: [
          { title: "Move task between columns", given: "a task is in the 'To Do' column", when: "the user drags the task to 'In Progress'", then: "the task status is updated and it appears in the new column" },
          { title: "Create custom column", given: "the user is viewing a project board", when: "the user adds a new column called 'Code Review'", then: "the column appears on the board and tasks can be moved to it" },
          { title: "Reorder columns", given: "the user has multiple columns on the board", when: "the user drags a column to a new position", then: "the column order is updated for all board viewers" },
          { title: "Set column WIP limit", given: "the user is editing board settings", when: "the user sets WIP limit of 3 for 'In Progress'", then: "a warning appears when the column has more than 3 tasks" }
        ] },
      { title: "Team Collaboration", description: "Real-time collaboration with comments, mentions, and activity feeds.", tag_list: "collaboration, communication, real-time",
        scenarios: [
          { title: "Comment on a task", given: "the user is viewing a task", when: "the user types a comment and submits", then: "the comment appears in the activity feed and assignee is notified" },
          { title: "Mention team member in comment", given: "the user is writing a comment on a task", when: "the user types @ and selects a team member", then: "the member is mentioned and receives a notification" },
          { title: "View activity feed", given: "the user is on a project", when: "the user opens the activity feed", then: "recent comments, status changes, and assignments are shown in chronological order" }
        ] },
      { title: "Time Tracking", description: "Track time spent on tasks with detailed reports and analytics.", tag_list: "time-tracking, reporting, analytics",
        scenarios: [
          { title: "Start time tracking", given: "the user is viewing a task", when: "the user clicks 'Start timer'", then: "the timer starts and elapsed time is shown on the task" },
          { title: "Log time manually", given: "the user has completed work on a task", when: "the user enters 2 hours in the time log and saves", then: "the time is recorded against the task and appears in reports" },
          { title: "View time report by project", given: "the user is on the reporting section", when: "the user selects a project and date range", then: "total and per-task time is displayed for the project" }
        ] }
    ]
  }
].freeze

# ---------------------------------------------------------------------------
# Run seeds
# ---------------------------------------------------------------------------

seed_cleanup!

admin_user = seed_admin_user
default_workspace = seed_default_workspace(admin_user)

puts "Creating projects..."

PROJECTS_SEED.each do |project_data|
  project = seed_project(
    default_workspace,
    name: project_data[:name],
    description: project_data[:description],
    admin_user: admin_user
  )

  (project_data[:features] || []).each do |feature_data|
    feature = seed_feature(
      project,
      title: feature_data[:title],
      description: feature_data[:description],
      tag_list: feature_data[:tag_list]
    )

    (feature_data[:scenarios] || []).each do |scenario_data|
      seed_scenario(
        feature,
        title: scenario_data[:title],
        given: scenario_data[:given],
        when_step: scenario_data[:when],
        then_step: scenario_data[:then]
      )
    end
  end
end

puts "Seeding complete! Created:"
puts "  - #{Project.count} projects"
puts "  - #{Feature.count} features"
puts "  - #{Scenario.count} scenarios"
