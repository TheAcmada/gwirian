# Gwirian

**A modern BDD (Behavior-Driven Development) feature management platform that helps teams collaborate, organize, and track their software features from conception to execution.**

Gwirian empowers development teams to manage their BDD features with ease. Create and organize features, define scenarios, track executions, and collaborate with your team—all in one beautiful, fast, and intuitive platform. Built with modern web technologies for a seamless experience.

## What Gwirian Does

### **Organize Your BDD Workflow**
Manage all your Behavior-Driven Development features in one place. Create features, define scenarios, and track their execution status across multiple projects. Keep your team aligned with a centralized view of your BDD specifications.

### **Powerful Search & Discovery**
Find features instantly with full-text search powered by Elasticsearch. Tag your features and scenarios for better organization and quick filtering. Never lose track of important specifications again.

### **Team Collaboration**
Invite team members to projects with role-based access control (administrator, editor, viewer). Manage project memberships, track who's working on what, and maintain clear ownership of features and scenarios.

### **Execution Tracking**
Monitor scenario executions to understand which features have been tested and their current status. Keep your team informed about the progress of your BDD specifications.

### **Secure & Auditable**
Built-in user authentication, password management, and login history tracking ensure your team's work is secure and auditable. Know who accessed what and when.

### **Modern & Fast**
Experience a lightning-fast interface built with the latest web technologies. Enjoy smooth interactions with Alpine.js, dynamic updates with htmx, and beautiful styling with Tailwind CSS v4—all without page reloads.

## Technical Features

- **Modern Stack:**
  - Ruby on Rails 8
  - Tailwind CSS v4
  - Alpine.js (latest)
  - htmx (latest)
  - ViewComponent
- **Production Ready:**
  - Dockerized for easy deployment
  - Kamal-ready for zero-downtime deploys

## Requirements
- Ruby 3.4
- Docker (for production/deployment)
- SQLite3 (default, or your preferred DB)

## Quick Start

Get up and running in minutes:

```sh
# 1. Clone and install
git clone https://github.com/frocher/gwirian.git
cd gwirian
bundle install

# 2. Start external services (Elasticsearch, Mailhog)
docker-compose up -d

# 3. Setup database
bin/rails db:create db:migrate db:seed

# 4. Start the development server
bin/dev
```

Visit [http://localhost:3000](http://localhost:3000) and you're ready to go!

> **Note:** Make sure Docker is running for the external services. If you need to reindex Elasticsearch after setup, run `bin/rails elasticsearch:reindex`.

## External Services (Docker Compose)
This app depends on external services for full functionality, which can be launched using Docker Compose:

- **Elasticsearch** (for feature search/indexing)
- **Mailhog** (for local email testing)

To start these services, run:
```sh
docker-compose up -d
```
- Elasticsearch will be available at [http://localhost:9200](http://localhost:9200)
- Mailhog UI will be available at [http://localhost:8025](http://localhost:8025)

## Setup & Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/frocher/gwirian.git
   cd gwirian
   ```
2. **Install dependencies:**
   ```sh
   bundle install
   ```
3. **Set up the database:**
   ```sh
   bin/rails db:create db:migrate
   bin/rails db:seed # optional
   ```
4. **Start the development server:**
   ```sh
   bin/dev
   ```
   - Visit [http://localhost:3000](http://localhost:3000)

## Elasticsearch

### Reindexing

If you need to recreate the Elasticsearch index (for example after schema changes, or to rebuild the index from scratch), run:

```sh
bin/rails elasticsearch:reindex
```

This task will:
1. Delete the existing Elasticsearch index for the `Feature` model (if it exists)
2. Create a new index with the proper settings and mappings
3. Import all features into the index

> **Note:** Make sure Elasticsearch is running before executing this command (`docker-compose up -d`).

## Development
- Tailwind CSS is auto-compiled via `bin/rails tailwindcss:watch` (see Procfile.dev)
- htmx and Alpine.js are included via `/js/htmx.min.js` and `/js/alpinejs.min.js`
- Main layout: `app/views/layouts/application.html.erb`
- ViewComponent components are located in `app/components/`

## Testing
```sh
bin/rails test
```

## Docker & Production
- Build and run with Docker:
  ```sh
  docker build -t gwirian .
  docker run -d -p 80:80 -e RAILS_MASTER_KEY=yourkey --name gwirian gwirian
  ```
- Kamal is supported for zero-downtime deploys (see [kamal-deploy.org](https://kamal-deploy.org))

## Configuration
- Environment variables: see `.env.example` (create `.env` as needed)
- Database config: `config/database.yml`
- Elasticsearch config: `config/initializers/elasticsearch.rb`

## Resources
- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [Tailwind CSS v4 Docs](https://tailwindcss.com/docs)
- [Alpine.js Docs](https://alpinejs.dev/start-here)
- [htmx Docs](https://htmx.org/docs/)
- [ViewComponent Docs](https://viewcomponent.org/)
- [Kamal Deploy](https://kamal-deploy.org)

---

Feel free to update this README with more specific information about your project, features, or deployment setup!
