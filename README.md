# Testtiz

A modern BDD (Behavior-Driven Development) feature management platform built with Ruby on Rails 8, styled with Tailwind CSS v4, interactive with Alpine.js, and dynamic with htmx. Containerized for production with Docker and Kamal.

## Core Features
- **Feature Management:** Create, edit, and manage BDD features for your projects. Features are indexed and searchable (Elasticsearch integration).
- **Scenario Management:** Define and organize scenarios within features, with support for execution tracking.
- **Project Management:** Create and manage multiple projects, each with its own features, scenarios, and team members.
- **Tagging Support:** Tag features and scenarios for better organization and filtering.
- **Project Membership & Roles:** Invite users to projects with roles (administrator, editor, viewer). Invitation and acceptance flow included.
- **User Authentication:** Secure registration, login, password reset, and profile management.
- **Login History:** Track user login history for security auditing.
- **Modern UI/UX:**
  - Tailwind CSS v4 for styling
  - Alpine.js (latest) for interactivity
  - htmx (latest) for dynamic HTML and partial updates
  - ViewComponent for reusable UI components
- **Containerized & Deployable:**
  - Dockerized for production
  - Kamal-ready for zero-downtime deploys

## Requirements
- Ruby 3.4
- Docker (for production/deployment)
- SQLite3 (default, or your preferred DB)

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
   git clone https://github.com/frocher/testtiz.git
   cd testtiz
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
  docker build -t testtiz .
  docker run -d -p 80:80 -e RAILS_MASTER_KEY=yourkey --name testtiz testtiz
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
