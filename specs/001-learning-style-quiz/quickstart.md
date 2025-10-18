# Quickstart: Learning Style Quiz

**Feature**: Learning Style Quiz (001-learning-style-quiz)
**Last Updated**: 2025-10-17

This guide helps you set up and run the Learning Style Quiz locally for development.

## Prerequisites

Before you begin, ensure you have:

- **Elixir 1.15+** and **Erlang 26+** installed
  ```bash
  elixir --version  # Should show Elixir 1.15+ and Erlang/OTP 26+
  ```

- **Node.js 18+** and **npm** installed
  ```bash
  node --version  # Should show v18+
  npm --version
  ```

- **PostgreSQL** (local) OR **Neon account** (recommended)
  - Local Postgres: Install via Homebrew (`brew install postgresql@15`)
  - Neon: Sign up at https://neon.tech (free tier)

- **Git** installed
  ```bash
  git --version
  ```

## Setup Steps

### 1. Clone and Checkout Feature Branch

```bash
# From the style project root
git checkout 001-learning-style-quiz

# Verify you're on the right branch
git branch --show-current  # Should show: 001-learning-style-quiz
```

### 2. Set Up Database

#### Option A: Using Neon (Recommended)

1. Sign up at https://neon.tech
2. Create a new project (e.g., "style-quiz-dev")
3. Copy the connection string (looks like: `postgres://user:pass@host/db`)
4. Create `.env` file in project root:

```bash
# .env
DATABASE_URL=postgresql://user:pass@ep-xxx.us-east-2.aws.neon.tech/style_quiz_dev
SECRET_KEY_BASE=run_mix_phx_gen_secret_to_generate_this
GA_TRACKING_ID=G-XXXXXXXXXX  # Your Google Analytics 4 ID (or leave empty for dev)
PHX_HOST=localhost
```

5. Generate secret key base:
```bash
mix phx.gen.secret
# Copy output to SECRET_KEY_BASE in .env
```

#### Option B: Using Local PostgreSQL

1. Start PostgreSQL:
```bash
brew services start postgresql@15
```

2. Create database:
```bash
createdb style_dev
createdb style_test
```

3. Create `.env` file:
```bash
# .env
DATABASE_URL=postgresql://postgres:postgres@localhost/style_dev
SECRET_KEY_BASE=run_mix_phx_gen_secret_to_generate_this
GA_TRACKING_ID=  # Empty for local dev
PHX_HOST=localhost
```

### 3. Install Backend Dependencies

```bash
# From project root
mix deps.get
mix deps.compile
```

### 4. Run Database Migrations and Seeds

```bash
# Create database (if using local Postgres, skip if using Neon)
mix ecto.create

# Run migrations
mix ecto.migrate

# Seed quiz content (questions, answers, learning styles)
mix run priv/repo/seeds/quiz_content.exs
```

**Verify seeds loaded**:
```bash
mix run -e "IO.inspect(Style.Repo.aggregate(Style.Quiz.Question, :count))"
# Should output: 6

mix run -e "IO.inspect(Style.Repo.aggregate(Style.Quiz.LearningStyle, :count))"
# Should output: 4
```

### 5. Install Frontend Dependencies

```bash
# Navigate to React app directory
cd assets/quiz

# Install dependencies
npm install

# Verify installation
npm list react  # Should show react@18.x
```

### 6. Start Development Servers

You'll need **two terminal windows**.

#### Terminal 1: Phoenix Backend (API)

```bash
# From project root
mix phx.server
```

You should see:
```
[info] Running StyleWeb.Endpoint with Bandit 1.5.0 at 127.0.0.1:4000 (http)
[info] Access StyleWeb.Endpoint at http://localhost:4000
```

**Test API**:
```bash
curl http://localhost:4000/api/v1/quiz/content | jq
# Should return JSON with questions and learning_styles
```

#### Terminal 2: React Frontend (Dev Server)

```bash
# From assets/quiz directory
npm run dev
```

You should see:
```
  VITE v5.x.x  ready in XXX ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h to show help
```

### 7. Open the App

Open your browser to: **http://localhost:5173**

You should see the quiz intro page: "What's Your Study Style?"

## Development Workflow

### Making Backend Changes

**Contexts and Schemas**: `lib/style/quiz/`
```bash
# Edit files in lib/style/quiz/
# Changes auto-reload thanks to Phoenix code reloader
```

**Controllers**: `lib/style_web/controllers/quiz_controller.ex`
```bash
# Edit controller
# Server reloads automatically
```

**Database Migrations**:
```bash
# Create new migration
mix ecto.gen.migration add_some_field

# Edit migration in priv/repo/migrations/

# Run migration
mix ecto.migrate

# Rollback if needed
mix ecto.rollback
```

**Seeds**:
```bash
# Edit priv/repo/seeds/quiz_content.exs

# Re-run seeds (idempotent)
mix run priv/repo/seeds/quiz_content.exs
```

### Making Frontend Changes

**Components**: `assets/quiz/src/components/`
```bash
# Edit React components
# Vite HMR updates instantly in browser (no refresh needed)
```

**State/Hooks**: `assets/quiz/src/hooks/`
```bash
# Edit custom hooks
# HMR applies changes automatically
```

**API Client**: `assets/quiz/src/services/api.ts`
```bash
# Edit API client
# Changes apply on next API call
```

**Styles**: `assets/quiz/src/*.css`
```bash
# Edit CSS
# HMR updates styles instantly
```

### Running Tests

**Backend Tests**:
```bash
# Run all tests
mix test

# Run specific test file
mix test test/style/quiz_test.exs

# Run with coverage
mix test --cover

# Watch mode (requires mix_test_watch dependency)
mix test.watch
```

**Frontend Tests**:
```bash
# From assets/quiz/
npm test

# Watch mode
npm test -- --watch

# Coverage
npm test -- --coverage
```

**API Contract Tests**:
```bash
# Test API endpoints match OpenAPI spec
mix test test/style_web/controllers/quiz_controller_test.exs
```

### Debugging

**Backend Debugging**:
```elixir
# Add to any Elixir file
require IEx
IEx.pry()  # Debugger will pause here when code runs
```

**Frontend Debugging**:
```javascript
// Add to any component
console.log('Debug:', someValue)
debugger;  // Browser will pause here (DevTools must be open)
```

**Database Queries**:
```bash
# Connect to database
psql $DATABASE_URL

# Or for local:
psql style_dev

# List tables
\dt

# Query questions
SELECT * FROM questions ORDER BY position;
```

## Common Tasks

### Reset Database

```bash
# Drop, create, migrate, seed
mix ecto.reset

# Verify seeds
mix run -e "IO.inspect(Style.Repo.aggregate(Style.Quiz.Question, :count))"
```

### Add New Question

1. Edit `priv/repo/seeds/quiz_content.exs`
2. Add question with 4 answers (each mapping to a learning style)
3. Update `position` (e.g., make it question 7)
4. Re-run seeds:
   ```bash
   mix run priv/repo/seeds/quiz_content.exs
   ```

### Change Learning Style Tips

1. Edit `priv/repo/seeds/quiz_content.exs`
2. Update `tips` array for the learning style
3. Re-run seeds (updates existing records)

### Enable CORS for Different Frontend Port

If running frontend on a different port:

1. Edit `lib/style_web/endpoint.ex`
2. Update CORS config:
   ```elixir
   plug Corsica,
     origins: ["http://localhost:5173", "http://localhost:YOUR_PORT"],
     allow_headers: ["content-type"],
     allow_methods: ["GET", "POST"]
   ```
3. Restart Phoenix server

### Format Code

**Backend**:
```bash
mix format
```

**Frontend**:
```bash
cd assets/quiz
npm run format  # Or: npx prettier --write src/
```

### Lint Code

**Backend**:
```bash
mix credo --strict
```

**Frontend**:
```bash
cd assets/quiz
npm run lint  # ESLint
```

## Troubleshooting

### Problem: "Connection refused" to database

**Solution**:
- Check DATABASE_URL in `.env` is correct
- If local Postgres: `brew services start postgresql@15`
- If Neon: Verify connection string and network access

### Problem: Frontend can't reach API (CORS error)

**Solution**:
- Verify Phoenix server is running on port 4000
- Check CORS config in `lib/style_web/endpoint.ex`
- Ensure frontend API client points to `http://localhost:4000`

### Problem: "Module not found" in React app

**Solution**:
```bash
cd assets/quiz
rm -rf node_modules package-lock.json
npm install
```

### Problem: Migrations fail

**Solution**:
```bash
# Check current migration status
mix ecto.migrations

# Rollback one migration
mix ecto.rollback

# Rollback all and re-run
mix ecto.reset
```

### Problem: Seeds not loading

**Solution**:
```bash
# Check for errors
mix run priv/repo/seeds/quiz_content.exs

# Reset database
mix ecto.reset

# Manually check database
psql $DATABASE_URL
SELECT * FROM learning_styles;
```

### Problem: Hot reload not working

**Backend**: Restart `mix phx.server`

**Frontend**:
```bash
cd assets/quiz
rm -rf node_modules/.vite
npm run dev
```

## Environment Variables Reference

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `DATABASE_URL` | Yes | PostgreSQL connection string | `postgresql://user:pass@host/db` |
| `SECRET_KEY_BASE` | Yes | Phoenix secret (generate with `mix phx.gen.secret`) | `long_random_string...` |
| `GA_TRACKING_ID` | No | Google Analytics 4 measurement ID | `G-XXXXXXXXXX` |
| `PHX_HOST` | Yes | Hostname for Phoenix | `localhost` (dev), `quiz.margaretsalty.com` (prod) |
| `PORT` | No | Phoenix server port | `4000` (default) |

## Next Steps

Once you have the app running locally:

1. **Read the spec**: Review `specs/001-learning-style-quiz/spec.md`
2. **Check the plan**: Review `specs/001-learning-style-quiz/plan.md`
3. **Review API contract**: Open `specs/001-learning-style-quiz/contracts/quiz-api.yaml`
4. **Explore data model**: Read `specs/001-learning-style-quiz/data-model.md`
5. **Ready to implement**: Proceed to `/speckit.tasks` to generate implementation tasks

## Useful Commands Cheat Sheet

```bash
# Backend
mix phx.server          # Start Phoenix server
mix test                # Run tests
mix ecto.reset          # Reset database
mix format              # Format Elixir code
mix credo --strict      # Lint code

# Frontend
npm run dev             # Start Vite dev server
npm test                # Run tests
npm run build           # Build for production
npm run format          # Format code
npm run lint            # Lint code

# Database
mix ecto.migrate        # Run migrations
mix ecto.rollback       # Rollback last migration
mix ecto.reset          # Drop, create, migrate, seed
psql $DATABASE_URL      # Connect to database
```

## Getting Help

- **Spec issues**: Review `specs/001-learning-style-quiz/spec.md`
- **API questions**: Check `specs/001-learning-style-quiz/contracts/quiz-api.yaml`
- **Database schema**: Read `specs/001-learning-style-quiz/data-model.md`
- **Tech decisions**: See `specs/001-learning-style-quiz/research.md`
- **Phoenix docs**: https://hexdocs.pm/phoenix
- **React docs**: https://react.dev
- **Vite docs**: https://vitejs.dev
