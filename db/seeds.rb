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

def seed_user(email_address)
  User.find_or_create_by!(email_address: email_address)
end

def seed_workspace_member(workspace, user, role: "viewer", status: "current_member")
  WorkspaceMember.find_or_create_by!(workspace: workspace, user: user) do |wm|
    wm.role = role
    wm.status = status
  end
end

def seed_project_member(project, email:, role: "editor")
  ProjectMember.find_or_create_by!(project: project, email: email) do |pm|
    pm.role = role
  end
end

def seed_scenario_execution(scenario, user, status:, executed_at:, notes: nil, tag_list: nil)
  execution = ScenarioExecution.create!(
    scenario: scenario,
    user: user,
    status: status,
    executed_at: executed_at,
    notes: notes.presence
  )
  if tag_list.present?
    execution.tag_list = tag_list
    execution.save!
  end
  execution
end

# ---------------------------------------------------------------------------
# Seed data: add or edit projects, features, and scenarios here
# ---------------------------------------------------------------------------

# 4 additional users (admin is created separately). Each gets workspace membership
# and is distributed across projects as below.
USERS_SEED = [
  { email: "alice@example.com" },
  { email: "bob@example.com" },
  { email: "carol@example.com" },
  { email: "dave@example.com" }
].freeze

# For each project name, list emails of non-admin members to add (must be in USERS_SEED).
# Each project ends up with 1 admin + these members, so total count varies 2–5 per project.
PROJECT_MEMBERS_SEED = {
  "E-Commerce Platform" => [ "alice@example.com" ],                                    # 2 total
  "Content Management System" => [ "alice@example.com", "bob@example.com" ],            # 3 total
  "Mobile Banking Application" => [ "alice@example.com", "bob@example.com", "carol@example.com" ], # 4 total
  "Task Management System" => [ "alice@example.com", "bob@example.com", "carol@example.com", "dave@example.com" ] # 5 total
}.freeze

# Template for scenario executions: status, days_ago, and notes (nil = no notes).
# Used to build a rich, representative set of executions across dates and outcomes.
EXECUTION_NOTE_TEMPLATES = {
  passed: [
    nil,
    "All steps green.",
    "Green in CI. No flakiness.",
    "Smoke test run. Environment: staging.",
    "Regression run completed. Coverage OK.",
    "Passed after fixing fixture data."
  ].freeze,
  failed: [
    "Timeout waiting for payment gateway response.",
    "Assertion failed: expected cart count 2, got 1.",
    "Element not found: Add to Cart button (selector changed).",
    "Flaky – passed on retry. Investigating.",
    "Stale element reference. Need explicit wait.",
    "API returned 502. Backend deployment in progress.",
    "Snapshot mismatch on checkout summary.",
    "Failed on Safari only. Cross-browser ticket created."
  ].freeze,
  pending: [
    nil,
    "Scheduled for nightly run.",
    "Blocked by API rate limit. Retry tomorrow.",
    "Skipped – env under maintenance.",
    "Waiting for design sign-off on new flow.",
    "Not run this cycle. Backlog."
  ].freeze
}.freeze

# One entry per execution to add per scenario: [status, days_ago, note_index_in_templates].
# Heavy bias toward recent (0–7 days); then spread up to ~60 days. Note index can be nil or 0, 1, ...
EXECUTION_TEMPLATES = [
  # Recent: today and last 2 days (many runs)
  [ :passed,  0,  0 ], [ :passed,  0,  1 ], [ :failed,  0,  0 ], [ :passed,  0,  2 ], [ :passed,  0, nil ],
  [ :passed,  1,  1 ], [ :passed,  1,  3 ], [ :failed,  1,  2 ], [ :pending,  1,  1 ], [ :passed,  1,  0 ],
  [ :passed,  2,  2 ], [ :failed,  2,  0 ], [ :passed,  2,  4 ], [ :passed,  2,  1 ], [ :passed,  2,  5 ],
  # Last week
  [ :passed,  3,  0 ], [ :failed,  3,  3 ], [ :passed,  4,  1 ], [ :passed,  4,  2 ], [ :failed,  5,  6 ],
  [ :passed,  5,  5 ], [ :pending,  6,  0 ], [ :passed,  6,  3 ], [ :passed,  7,  2 ], [ :failed,  7,  4 ],
  # 2–4 weeks and older
  [ :pending, 10, 1 ], [ :passed,  14, 3 ], [ :failed,  21,  2 ], [ :passed,  28, 4 ],
  [ :passed,  35, 0 ], [ :failed,  42, 5 ], [ :passed,  49, 1 ], [ :pending, 56, 3 ],
  [ :passed,  60, 0 ], [ :failed,  5,  6 ], [ :passed,  12, 5 ], [ :pending, 18, 0 ],
  [ :passed,  25, 2 ], [ :failed,  33, 3 ], [ :passed,  45, nil ], [ :pending, 52, 4 ]
].freeze

# Tag lists for scenario executions (nil = no tags). Indexed deterministically per execution.
EXECUTION_TAG_LISTS = [
  "ci, main",
  "staging, smoke",
  "manual, regression",
  "ci, nightly",
  "staging",
  nil,
  "ci",
  "manual",
  "ci, pr",
  "staging, e2e",
  "manual",
  "ci, release",
  "playwright",
  "smoke"
].freeze

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
          { title: "Cart persists across sessions", given: "the user added items to the cart while logged in", when: "the user returns to the site in a new session", then: "the cart still contains the previously added items" },
          { title: "Cart icon shows total count", given: "the user has two items in the cart", when: "the user views any page with the header", then: "the cart icon badge displays 2" }
        ] },
      { title: "Payment Processing", description: "Secure payment processing with support for credit cards, PayPal, and other payment methods.", tag_list: "critical-path, payment, security, checkout",
        scenarios: [
          { title: "Successful credit card payment", given: "the user has items in the cart and is on the checkout page", when: "the user enters valid credit card details and clicks 'Pay'", then: "the payment is processed and the order confirmation is displayed" },
          { title: "Payment declined", given: "the user is on the checkout page", when: "the user enters an invalid credit card number", then: "an error message is displayed and the user can retry" },
          { title: "Pay with PayPal", given: "the user has items in the cart and selected PayPal at checkout", when: "the user completes authentication in the PayPal popup", then: "the payment is processed and the order confirmation is displayed" },
          { title: "Save card for future use", given: "the user is on the checkout page", when: "the user checks 'Save this card' and completes payment", then: "the card is stored and available for future checkouts" },
          { title: "3D Secure verification", given: "the user's card requires 3DS", when: "the user completes the bank challenge in the modal", then: "payment proceeds and order is confirmed" }
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
        ] },
      { title: "Wishlist", description: "Save items for later with a personal wishlist that syncs across devices.", tag_list: "wishlist, user-experience, conversion",
        scenarios: [
          { title: "Add product to wishlist", given: "the user is viewing a product page", when: "the user clicks the heart or 'Add to wishlist' button", then: "the product is added to the wishlist and the counter updates" },
          { title: "Move wishlist item to cart", given: "the user has items in their wishlist", when: "the user clicks 'Add to cart' on a wishlist item", then: "the item is added to the cart and can be removed from wishlist" },
          { title: "Share wishlist", given: "the user has a non-empty wishlist", when: "the user clicks 'Share wishlist' and copies the link", then: "the link opens a read-only view of the wishlist for others" },
          { title: "Wishlist persists when logged in", given: "the user is logged in and added items to wishlist", when: "the user returns later from another device", then: "the same wishlist items are visible" }
        ] },
      { title: "Guest Checkout", description: "Allow one-time purchases without creating an account.", tag_list: "checkout, conversion, critical-path",
        scenarios: [
          { title: "Checkout as guest with email", given: "the user has items in the cart and is not logged in", when: "the user selects 'Checkout as guest' and enters email and shipping details", then: "the order is placed and a confirmation email is sent" },
          { title: "Guest offered account creation after order", given: "the user just completed a guest checkout", when: "the order confirmation page is shown", then: "an option to create an account with the same email is offered" },
          { title: "Guest cannot access order history", given: "the user completed a guest checkout", when: "the user returns to the site without logging in", then: "there is no order history; they must use the confirmation link or email" }
        ] },
      { title: "Returns and Refunds", description: "Self-service returns and refund processing within policy window.", tag_list: "returns, customer-service, payments",
        scenarios: [
          { title: "Initiate return within window", given: "the user has an order delivered within the return window", when: "the user opens the order and clicks 'Start return'", then: "the return is created and a prepaid label can be printed" },
          { title: "Refund to original payment method", given: "a return has been received and approved", when: "the warehouse marks the return as accepted", then: "the refund is issued to the original payment method within 5–10 days" },
          { title: "Return outside window rejected", given: "the user's order is past the return window", when: "the user tries to start a return", then: "a message explains the window has passed and suggests contacting support" }
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
          { title: "Preview before publish", given: "the user is editing an article", when: "the user clicks 'Preview'", then: "a read-only preview opens in a new tab showing how the article will appear" },
          { title: "Autosave draft", given: "the user is editing an article", when: "the user types and pauses for a few seconds", then: "the draft is saved automatically and a saved indicator is shown" }
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
        ] },
      { title: "Version History", description: "Track and restore previous versions of articles and pages.", tag_list: "versioning, audit, content-safety",
        scenarios: [
          { title: "View version history", given: "the user is editing an article that has been saved before", when: "the user opens the version history panel", then: "a list of previous versions with date and author is shown" },
          { title: "Restore previous version", given: "the user is viewing version history", when: "the user selects a past version and clicks 'Restore'", then: "the content is reverted to that version and a new version entry is created" },
          { title: "Compare two versions", given: "the user has version history open", when: "the user selects two versions and clicks 'Compare'", then: "a diff view shows added, removed, and changed content" }
        ] },
      { title: "Multi-language Content", description: "Create and manage content in multiple languages with fallbacks.", tag_list: "i18n, localization, content",
        scenarios: [
          { title: "Add translation for article", given: "the user has an article in the default language", when: "the user selects 'Add translation' and chooses a language", then: "a new draft is created for that language linked to the original" },
          { title: "View site in alternate language", given: "translations exist for a page", when: "a visitor switches language via the locale selector", then: "the page content is shown in the selected language or fallback" },
          { title: "Missing translation shows fallback", given: "a translation is missing for a given language", when: "the user views the page in that language", then: "the default language content is shown with a fallback indicator" }
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
        ] },
      { title: "Biometric Login", description: "Sign in with Face ID or fingerprint for faster, secure access.", tag_list: "mobile, security, authentication",
        scenarios: [
          { title: "Enable Face ID after password", given: "the user is logged in with password", when: "the user goes to Security and enables Face ID", then: "next launch offers Face ID as the primary login" },
          { title: "Fallback to password when biometric fails", given: "the user has biometric login enabled", when: "Face ID or fingerprint fails or is cancelled", then: "the user can tap 'Use password' and sign in normally" },
          { title: "Biometric disabled when credentials change", given: "the user has changed their password or security settings", when: "the user next opens the app", then: "biometric is disabled and password login is required once" }
        ] },
      { title: "Card Management", description: "View and control debit and credit cards: freeze, limits, and spending insights.", tag_list: "mobile, cards, security",
        scenarios: [
          { title: "Freeze card temporarily", given: "the user is viewing their card details", when: "the user toggles 'Freeze card'", then: "the card is declined for new transactions until unfrozen" },
          { title: "Set spending limit on card", given: "the user has a card with limit controls", when: "the user sets a daily spending limit of $500", then: "transactions are declined once the daily total exceeds $500" },
          { title: "View card transactions", given: "the user is on the card detail screen", when: "the user taps 'Recent transactions'", then: "transactions for that card only are listed" }
        ] },
      { title: "Alerts and Notifications", description: "Configurable push and in-app alerts for transactions, balance, and security.", tag_list: "mobile, notifications, security",
        scenarios: [
          { title: "Enable low balance alert", given: "the user is in notification settings", when: "the user sets a low balance alert at $100", then: "a push notification is sent when balance drops below $100" },
          { title: "Transaction alert for large amount", given: "the user enables transaction alerts", when: "a transaction over $200 is posted", then: "the user receives an immediate notification with amount and merchant" },
          { title: "Turn off marketing notifications", given: "the user is in notification preferences", when: "the user disables marketing and promotions", then: "only security and account alerts are sent" }
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
          { title: "Add subtasks", given: "the user is editing a task", when: "the user adds two subtasks with titles", then: "the subtasks appear under the task and progress can be tracked" },
          { title: "Duplicate task", given: "the user is viewing a task", when: "the user selects 'Duplicate'", then: "a copy of the task is created in the same list with title prefixed by 'Copy of'" }
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
        ] },
      { title: "Labels and Tags", description: "Organize tasks with labels, tags, and custom fields for filtering and reporting.", tag_list: "organization, filtering, productivity",
        scenarios: [
          { title: "Add label to task", given: "the user is editing a task", when: "the user adds the label 'bug'", then: "the task shows the label and can be filtered by it" },
          { title: "Filter board by label", given: "the user is viewing a project board", when: "the user selects the 'urgent' label filter", then: "only tasks with that label are shown on the board" },
          { title: "Create new label", given: "the user is in project settings or the label picker", when: "the user creates a new label with name and color", then: "the label is available for all tasks in the project" }
        ] },
      { title: "Recurring Tasks", description: "Create tasks that repeat on a schedule (daily, weekly, or custom).", tag_list: "automation, productivity, scheduling",
        scenarios: [
          { title: "Create weekly recurring task", given: "the user is creating a task", when: "the user sets recurrence to 'Every Monday'", then: "the task is created and a new copy appears each Monday" },
          { title: "Complete instance of recurring task", given: "a recurring task has generated today's instance", when: "the user marks the instance complete", then: "only that instance is completed; the series continues" },
          { title: "Edit series vs single instance", given: "the user is editing a recurring task instance", when: "the user chooses 'Edit this occurrence'", then: "only that instance is changed; the series is unchanged" }
        ] },
      { title: "Integrations", description: "Connect to Slack, GitHub, calendar, and other tools for notifications and sync.", tag_list: "integrations, automation, collaboration",
        scenarios: [
          { title: "Connect Slack workspace", given: "the user has admin access to the project", when: "the user goes to Integrations and connects Slack", then: "task updates and mentions can be posted to a chosen channel" },
          { title: "Create task from Slack message", given: "Slack integration is connected", when: "the user uses the /task command with a title in Slack", then: "a new task is created in the linked project and link is posted back" },
          { title: "GitHub PR links to task", given: "GitHub integration is set up", when: "a PR description contains the task ID", then: "the task shows the linked PR and status updates when the PR is merged" }
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

puts "Creating users..."
seed_users = USERS_SEED.map { |u| seed_user(u[:email]) }
# Add all 4 as workspace members: 2 editors, 2 viewers
seed_users.each_with_index do |user, i|
  role = i < 2 ? "editor" : "viewer"
  seed_workspace_member(default_workspace, user, role: role)
end

puts "Creating projects..."
projects_by_name = {}
PROJECTS_SEED.each do |project_data|
  project = seed_project(
    default_workspace,
    name: project_data[:name],
    description: project_data[:description],
    admin_user: admin_user
  )
  projects_by_name[project_data[:name]] = project

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

puts "Adding project members..."
PROJECT_MEMBERS_SEED.each do |project_name, emails|
  project = projects_by_name[project_name]
  next unless project

  emails.each do |email|
    seed_project_member(project, email: email, role: "editor")
  end
end

puts "Creating scenario executions..."
all_users = [ admin_user ] + seed_users
Scenario.includes(:feature).find_each do |scenario|
  # Number of executions per scenario: 12–22, deterministic from scenario id (more data, recent-heavy)
  count = 12 + (scenario.id % 11)
  count.times do |i|
    template = EXECUTION_TEMPLATES[(scenario.id + i) % EXECUTION_TEMPLATES.size]
    status_sym, days_ago, note_idx = template
    status = status_sym.to_s
    # For today (days_ago 0), spread executions over the last 8 hours so they feel recent
    executed_at = if days_ago.zero?
      offset_sec = (scenario.id * 37 + i * 11) % (8 * 3600)
      offset_sec.seconds.ago
    else
      days_ago.days.ago + (scenario.id * 37 + i * 11).seconds
    end
    notes = if note_idx.nil?
      nil
    else
      arr = EXECUTION_NOTE_TEMPLATES[status_sym]
      arr[note_idx % arr.size] if arr
    end
    user = all_users[(scenario.id + i) % all_users.size]
    tag_list = EXECUTION_TAG_LISTS[(scenario.id + i) % EXECUTION_TAG_LISTS.size]
    seed_scenario_execution(
      scenario,
      user,
      status: status,
      executed_at: executed_at,
      notes: notes,
      tag_list: tag_list
    )
  end
end

puts "Seeding complete! Created:"
puts "  - #{User.count} users"
puts "  - #{WorkspaceMember.count} workspace members"
puts "  - #{Project.count} projects"
puts "  - #{ProjectMember.count} project members"
puts "  - #{Feature.count} features"
puts "  - #{Scenario.count} scenarios"
puts "  - #{ScenarioExecution.count} scenario executions"
