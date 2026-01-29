<!-- Tokens: ~1,400 (target: 1,500) | Lines: 82 | Compatibility: Claude Code 2.1+ -->
# Rails Project

A Ruby on Rails 7+ application with Hotwire and modern conventions.

## Stack

- **Framework**: Rails 7.1+
- **Language**: Ruby 3.3+
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Database**: PostgreSQL
- **Testing**: RSpec + Capybara
- **CSS**: Tailwind CSS
- **Package Manager**: Bundler + Importmap

## Commands

```bash
bin/rails server              # Start dev server (localhost:3000)
bin/rails console             # Rails console
bin/rails test                # Run Minitest (if used)
bundle exec rspec             # Run RSpec tests
bundle exec rspec --format doc  # Verbose output
bin/rails db:migrate          # Run migrations
bin/rails db:rollback         # Rollback last migration
bin/rails db:seed             # Seed database
bin/rails routes              # List all routes
bundle exec rubocop           # Lint code
bundle exec rubocop -a        # Auto-fix
```

## Key Directories

```
app/
├── controllers/      # Request handling
├── models/           # Active Record models
├── views/            # ERB templates
├── components/       # ViewComponent (if used)
├── helpers/          # View helpers
├── jobs/             # Active Job background jobs
├── mailers/          # Action Mailer
└── javascript/
    └── controllers/  # Stimulus controllers

config/
├── routes.rb         # Route definitions
└── database.yml      # Database configuration

db/
├── migrate/          # Migration files
└── schema.rb         # Current schema

spec/
├── models/           # Model specs
├── requests/         # Request specs
└── system/           # System specs (Capybara)
```

## Code Standards

- Fat models, skinny controllers
- Use concerns for shared model logic
- Service objects for complex business logic
- Strong parameters for mass assignment

## Architecture Decisions

- Turbo Frames for partial page updates
- Turbo Streams for real-time updates
- Stimulus for JavaScript sprinkles
- ViewComponent for reusable UI components

## Gotchas

- `bin/dev` uses Foreman for Procfile.dev (CSS/JS watching)
- Credentials: `bin/rails credentials:edit` (needs EDITOR env)
- Zeitwerk autoloading: file names must match class names
- `has_many` dependent: set `:destroy` or `:nullify`

## Model Pattern

```ruby
class User < ApplicationRecord
  has_many :posts, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }

  def full_name
    "#{first_name} #{last_name}"
  end
end
```

## Stimulus Controller

```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```

## Environment Variables

Rails credentials or environment:

```
DATABASE_URL=postgres://...
RAILS_MASTER_KEY=...
SECRET_KEY_BASE=...
```

## Testing Strategy

- Model specs: Validations, associations, scopes
- Request specs: Controller actions, JSON APIs
- System specs: Full browser flows (Capybara)
- Use FactoryBot for test data
