# Gwirian

**A modern BDD (Behavior-Driven Development) feature management platform that helps teams collaborate, organize, and track their software features from conception to execution.**

Gwirian empowers development teams to manage their BDD features with ease. Create and organize features, define scenarios, track executions, and collaborate with your team—all in one beautiful, fast, and intuitive platform. Built with modern web technologies for a seamless experience.

## Table of Contents

- [What Gwirian Does](#what-gwirian-does)
- [Key Features](#key-features)
- [Architecture Overview](#architecture-overview)
- [Technical Stack](#technical-stack)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Development](#development)
- [Testing](#testing)
- [External Services](#external-services)
- [MCP Server](#mcp-server)
- [Deployment](#deployment)
- [Configuration](#configuration)
- [Resources](#resources)

## What Gwirian Does

### **Organize Your BDD Workflow**
Manage all your Behavior-Driven Development features in one place. Create features, define scenarios with Given/When/Then steps, and track their execution status across multiple projects. Keep your team aligned with a centralized view of your BDD specifications.

### **Multi-Workspace Organization**
Organize your work into workspaces, each containing multiple projects. Perfect for teams managing multiple products or clients. Workspace members can have different roles (owner, admin, viewer) with fine-grained access control.

### **Powerful Search & Discovery**
Find features instantly with full-text search powered by Elasticsearch. Tag your features and scenarios for better organization and quick filtering. Never lose track of important specifications again.

### **Team Collaboration**
Invite team members to workspaces and projects with role-based access control. Manage project memberships, track who's working on what, and maintain clear ownership of features and scenarios.

### **Execution Tracking**
Monitor scenario executions to understand which features have been tested and their current status (pending, passed, failed). Keep your team informed about the progress of your BDD specifications with detailed execution history.

### **Secure & Auditable**
Passwordless magic link authentication via email. Login history tracking ensures your team's work is secure and auditable. Know who accessed what and when.

### **Modern & Fast**
Experience a lightning-fast interface built with the latest web technologies. Navigation uses **htmx** so links and shortcuts update only the main content—no full page reloads. Enjoy smooth, reactive UI with **Alpine.js**, beautiful styling with **Tailwind CSS v4**, and a **global command palette** (Ctrl+K / ⌘K) for search and quick navigation. The app is keyboard-first: use **G** then a letter for project navigation (Linear-style) and **?** to view all shortcuts.


## Key Features

- **Workspaces**: Organize teams and projects into separate workspaces
- **Projects**: Group related features within a workspace
- **Features**: Define BDD features with descriptions and backgrounds
- **Scenarios**: Create scenarios with Given/When/Then structure
- **Steps**: Define detailed steps for each scenario
- **Executions**: Track scenario execution status and history
- **Tags**: Organize features and scenarios with flexible tagging
- **Search**: Full-text search powered by Elasticsearch; instant search from the global command palette (Ctrl+K)
- **BDD Export**: Download a project ZIP containing `project_info.md` and one Gherkin `.feature` file per feature
- **Global command palette**: One shortcut (Ctrl+K) for search, navigation, and actions—no full page reloads
- **Keyboard-first navigation**: G-nav (G + letter) and shortcuts overlay (?); prev/next feature (G P / G N)
- **API Access**: Workspace-scoped API tokens for programmatic access
- **MCP Integration**: Model Context Protocol server for AI assistant integration

## Architecture Overview

### Data Model

Gwirian follows a hierarchical structure:

```
Workspace
  ├── Workspace Members (users with roles)
  └── Projects
      ├── Project Members (email-based access)
      └── Features
          ├── Tags
          └── Scenarios
              ├── Steps (Given/When/Then)
              └── Scenario Executions
```

### Authentication

- **Magic Links**: Passwordless authentication via email links (6-character code)
- **Sessions**: Database-backed session management with expiration
- **API Tokens**: Workspace-scoped tokens for programmatic access

### Authorization

- **CanCanCan**: Role-based authorization throughout the application
- **Workspace Roles**: Owner, Admin, Viewer
- **Project Access**: Email-based project membership with roles

### Background Jobs

- **Solid Queue**: Database-backed job queue (no Redis required)
- **Solid Cache**: Database-backed caching
- **Solid Cable**: Database-backed Action Cable

## Technical Stack

### Core Technologies

- **Ruby 4.0.0**: Modern Ruby runtime
- **Rails 8.0**: Latest Rails framework
- **SQLite3**: Default database (easily switchable to PostgreSQL/MySQL)
- **Tailwind CSS v4**: Utility-first CSS framework
- **Alpine.js**: Lightweight JavaScript framework for interactivity
- **htmx**: Dynamic HTML interactions without page reloads
- **ViewComponent**: Reusable UI components

### Key Gems

- **Elasticsearch**: Full-text search and indexing
- **CanCanCan**: Authorization framework
- **acts-as-taggable-on**: Flexible tagging system
- **acts_as_list**: Sortable list support
- **Pagy**: Fast, efficient pagination
- **Solid Queue/Cache/Cable**: Database-backed background jobs, caching, and WebSockets
- **Kamal**: Zero-downtime deployment
- **Thruster**: HTTP asset caching/compression for Puma

### Development Tools

- **RSpec**: Testing framework
- **FactoryBot**: Test data generation
- **Rubocop**: Code style enforcement
- **Brakeman**: Security vulnerability scanner
- **Capybara**: System testing

## Requirements

- **Ruby 4.0.0** (see `.ruby-version`)
- **Docker** and **Docker Compose** (for Elasticsearch and Mailhog)
- **Bundler** (Ruby gem manager)
- **Node.js** (for Tailwind CSS compilation)

## Quick Start

Get up and running in minutes:

```bash
# 1. Clone the repository
git clone https://github.com/TheAcmada/gwirian.git
cd gwirian

# 2. Install dependencies
bundle install

# 3. Start external services (Elasticsearch, Mailhog)
docker-compose up -d

# 4. Setup database
bin/rails db:create db:migrate db:seed

# 5. Reindex Elasticsearch
bin/rails elasticsearch:reindex

# 6. Start the development server
bin/dev
```

Visit [http://localhost:3000](http://localhost:3000) and sign in with your email address. You'll receive a magic link code via email (or check the browser console/response headers in development for the code).

> **Note**: The development server runs both the Rails server and Tailwind CSS watcher via `Procfile.dev`. Make sure Elasticsearch is running before reindexing.

## Development

### Starting the Server

The `bin/dev` command starts both the Rails server and Tailwind CSS watcher:

```bash
bin/dev
```

This uses `Procfile.dev` which runs:
- `web`: Rails server (port 3000)
- `css`: Tailwind CSS watcher for auto-compilation

### Development Workflow

- **Tailwind CSS**: Auto-compiled via `bin/rails tailwindcss:watch` (included in `bin/dev`)
- **htmx and Alpine.js**: Imported with importmap pins in `config/importmap.rb` and vendored files in `vendor/javascript/`
- **Main layout**: `app/views/layouts/application.html.erb`
- **ViewComponent components**: Located in `app/components/`
- **Models**: Located in `app/models/`
- **Controllers**: Located in `app/controllers/`

### BDD Export Workflow

Project readers can use the **Export** action on a project dashboard to download a ZIP archive of the current BDD specification. The export route is `GET /:workspace_slug/projects/:id/export_bdd` and requires normal project read access.

The ZIP contains:
- `project_info.md` with the project name, description, and context.
- One `.feature` file per feature, ordered by title. File names are generated from the feature title and duplicate names receive a numeric suffix.

Generated Gherkin includes feature tags, descriptions, background text, and each scenario's Given/When/Then fields. The export uses the data currently stored in the database; if search indexes are stale, export output is unaffected.

### Database Management

```bash
# Create database
bin/rails db:create

# Run migrations
bin/rails db:migrate

# Reset database (drop, create, migrate, seed)
bin/rails db:reset

# Load seed data
bin/rails db:seed
```

### Elasticsearch Management

```bash
# Reindex all features and scenario executions
bin/rails elasticsearch:reindex
```

This task will:
1. Delete existing Elasticsearch indices (if they exist)
2. Create new indices with proper settings and mappings
3. Import all features and scenario executions into the indices

> **Note**: Make sure Elasticsearch is running before executing this command (`docker-compose up -d`).

The development `docker-compose.yml`, CI workflow, and Kamal accessory pin concrete Elasticsearch image versions for their own environments. Keep the app's search behavior verified against the version you operate, and reindex after changing mappings or importing large data sets.

## Testing

Gwirian uses both RSpec and Rails' built-in test framework:

```bash
# Run all tests
bundle exec rspec && bin/rails test

# Run only RSpec tests
bundle exec rspec

# Run only Rails tests
bin/rails test

# Run a specific test file
bundle exec rspec spec/path/to/file_spec.rb
bin/rails test test/path/to/file_test.rb

# Run tests in parallel (if configured)
bundle exec rspec --parallel
```

### Test Data

- **FactoryBot**: Used for generating test data in RSpec
- **Fixtures**: Used for Rails tests

## External Services

This app depends on external services for full functionality, which can be launched using Docker Compose:

### Services

- **Elasticsearch** (port 9200): Full-text search and indexing
  - Available at [http://localhost:9200](http://localhost:9200)
  - Health check: `curl http://localhost:9200`

- **Mailhog** (ports 8025, 1025): Local email testing
  - Web UI: [http://localhost:8025](http://localhost:8025)
  - SMTP: `localhost:1025`

### Starting Services

```bash
# Start all services in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## MCP Server

Gwirian includes a **Model Context Protocol (MCP) server** that allows AI assistants and other tools to interact with your BDD features, scenarios, and executions programmatically.

For complete configuration, usage instructions, and available tools, see the [MCP Client Configuration Guide](docs/mcp.md).

## Deployment

Gwirian uses **Kamal** for zero-downtime deployments. Kamal provides a simple, Docker-based deployment workflow that works with any hosting provider.

### Prerequisites

- Docker installed on your server
- SSH access to your server
- Domain name configured

### Deployment Guide

For a complete walkthrough, see the [Kamal deployment guide](docs/kamal-deployment.md) or the [Docker deployment guide](docs/docker-deployment.md).

### Quick Deploy

```bash
# Deploy to production
bin/kamal deploy

# Deploy with specific environment
bin/kamal deploy -d production

# View deployment configuration
cat config/deploy.yml
```

### Deployment Features

- Zero-downtime deployments
- Automatic health checks
- Rollback support
- Environment-specific configurations
- Elasticsearch service included in deployment

## Configuration

### Environment Variables

Gwirian reads configuration from process environment variables. Supply them from your shell, process manager, Docker command, Kamal secrets/clear environment, or another tool that loads a local `.env` file.

```bash
# Elasticsearch
ELASTICSEARCH_URL=http://localhost:9200

# Email and links
MAILER_FROM_ADDRESS="Gwirian <support@example.com>"
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USERNAME=
SMTP_PASSWORD=
BASE_URL=http://localhost:3000

# Optional runtime tuning
PORT=3000
RAILS_LOG_LEVEL=info
RAILS_ENV=development
```

For production Docker and Kamal deployments, provide `RAILS_MASTER_KEY` so Rails can decrypt credentials. See the deployment guides for the required runtime settings.

### Configuration Files

- **Database**: `config/database.yml`
- **Elasticsearch**: `config/initializers/elasticsearch.rb`
- **Routes**: `config/routes.rb`
- **Application**: `config/application.rb`
- **Environments**: `config/environments/`

## Resources

### Documentation

- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [Tailwind CSS v4 Docs](https://tailwindcss.com/docs)
- [Alpine.js Docs](https://alpinejs.dev/start-here)
- [htmx Docs](https://htmx.org/docs/)
- [ViewComponent Docs](https://viewcomponent.org/)
- [Kamal Deploy](https://kamal-deploy.org)
- [Elasticsearch Ruby Client](https://github.com/elastic/elasticsearch-ruby)

### Project Documentation

- [MCP Client Configuration Guide](docs/mcp.md)
- [Kamal Deployment Guide](docs/kamal-deployment.md)
- [Docker Deployment Guide](docs/docker-deployment.md)

### Community

- [GitHub Issues](https://github.com/TheAcmada/gwirian/issues)
- [GitHub Discussions](https://github.com/TheAcmada/gwirian/discussions)

---

**Built with ❤️ for BDD teams everywhere**
