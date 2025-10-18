# Research: Learning Style Quiz

**Date**: 2025-10-17
**Feature**: Learning Style Quiz (001-learning-style-quiz)
**Purpose**: Document technology decisions, patterns, and best practices for implementation

## Technology Decisions

### 1. Frontend: React 18 + TypeScript + Vite

**Decision**: Use React 18 with TypeScript and Vite as the build tool

**Rationale**:
- **React 18**: Latest stable version with concurrent features, improved performance
- **TypeScript**: Type safety reduces bugs, better IDE support, self-documenting code
- **Vite**: Fast development server (HMR <50ms), optimized production builds, modern ESM-based

**Best Practices**:
- Use functional components with hooks (useState, useEffect, useContext)
- Custom hooks for reusable logic (useQuiz, useAnalytics)
- Component composition over inheritance
- Keep components small (<200 lines)
- Colocate types with components when specific, shared types in `/types`

**Alternatives Considered**:
- **Next.js**: Overkill for simple SPA, adds SSR complexity not needed
- **Create React App**: Deprecated, slower builds than Vite
- **Vue/Svelte**: Team familiarity with React, larger ecosystem

### 2. Backend: Phoenix 1.8.1 JSON API

**Decision**: Phoenix as JSON API only (no LiveView, no server-rendered HTML)

**Rationale**:
- Leverages existing Phoenix infrastructure
- Phoenix excellent for JSON APIs (fast, reliable, good error handling)
- Ecto for database layer with compile-time guarantees
- Easy CORS configuration for SPA communication
- Familiar to team

**Best Practices**:
- RESTful API design following JSON:API or similar conventions
- Use Phoenix contexts for business logic (Quiz, Analytics)
- Changesets for data validation
- API versioning via routes (`/api/v1/...`)
- Comprehensive error responses with proper HTTP status codes

**Alternatives Considered**:
- **Rails API**: Not in tech stack, slower than Phoenix
- **Node/Express**: Already have Phoenix, prefer Elixir's reliability
- **Serverless (AWS Lambda)**: Over-engineered for simple quiz API

### 3. Database: Neon (Serverless PostgreSQL)

**Decision**: Use Neon's serverless PostgreSQL

**Rationale**:
- **Free tier**: Generous limits (512MB storage, 0.5GB RAM) sufficient for quiz data
- **Serverless**: Auto-scaling, pay for what you use
- **PostgreSQL**: Full Postgres compatibility, works with Ecto
- **Low latency**: Edge network for global performance
- **Branching**: Can create DB branches for testing (unique feature)

**Best Practices**:
- Configure connection pooling (Neon has connection limits)
- Use Ecto migrations for all schema changes
- Seed data for quiz questions/learning styles (version controlled)
- Indexes on frequently queried fields (e.g., submission timestamps)
- UUID primary keys for submissions (better for distributed systems)

**Alternatives Considered**:
- **Heroku Postgres**: More expensive, slower provisioning
- **Supabase**: Overkill (includes auth, storage, realtime we don't need)
- **Railway**: Good but Neon's branching feature is valuable for testing

### 4. Hosting: Fly.io

**Decision**: Deploy to Fly.io with custom domain

**Rationale**:
- **Global edge network**: Fast response times worldwide
- **Elixir-friendly**: Excellent Phoenix deployment docs
- **Free tier**: Sufficient for initial traffic (3 shared VMs)
- **Custom domains**: Easy CNAME setup for quiz.margaretsalty.com
- **Docker-based**: Flexible deployment (can include React build)
- **Database proximity**: Can deploy near Neon regions for low latency

**Best Practices**:
- Multi-stage Dockerfile (build React app → copy into Phoenix static)
- Use fly.toml for configuration
- Set up health checks for auto-restart
- Configure environment variables via Fly secrets
- Enable metrics for monitoring

**Alternatives Considered**:
- **Heroku**: More expensive, slower deployments
- **Vercel/Netlify**: Great for frontend but need separate backend hosting
- **AWS/GCP**: Over-engineered, more complex setup

### 5. Analytics: Google Analytics 4

**Decision**: Integrate Google Analytics 4 for tracking

**Rationale**:
- **Lead gen requirement**: Must track conversions, completion rates
- **Free tier**: Unlimited events for our scale
- **Integration**: Simple gtag.js script tag
- **Custom events**: Track quiz start, question progress, completions, email captures
- **Familiar**: Marketing team knows GA4

**Best Practices**:
- Load GA script in index.html (before app mounts)
- Create custom events: `quiz_started`, `quiz_completed`, `result_{style}`, `email_captured`
- Track user properties: learning_style result, quiz_completion_time
- Use React hook (useAnalytics) to centralize tracking calls
- Test in GA4 DebugView before production

**Alternatives Considered**:
- **Plausible/Fathom**: Privacy-focused but costs money, GA4 free
- **Mixpanel**: Overkill for simple quiz, more expensive
- **Self-hosted**: Not worth the infrastructure overhead

## Architecture Patterns

### API Communication Pattern

**Decision**: REST API with JSON responses

**Endpoints Design**:
```
GET  /api/v1/quiz/content        → Returns all questions + learning styles
POST /api/v1/quiz/submissions    → Submit quiz answers (optional tracking)
GET  /api/v1/quiz/results/:id    → Get shareable result (P3 feature)
```

**Best Practices**:
- Use HTTP status codes correctly (200, 201, 400, 404, 500)
- Consistent error format: `{"error": "message", "details": {...}}`
- CORS headers for local dev (localhost:5173) and production domain
- API versioning in URL path (`/api/v1/`)
- Pagination for any list endpoints (future-proofing)

### State Management Pattern

**Decision**: React Context + localStorage for client-side state

**Rationale**:
- **Quiz answers**: Store in React state + localStorage (persist on refresh)
- **Quiz content**: Fetch once, cache in memory (doesn't change)
- **No Redux needed**: Simple state, Context sufficient
- **localStorage**: Survives page refresh (better UX than losing progress)

**State Structure**:
```typescript
interface QuizState {
  currentQuestion: number
  answers: Record<number, string>  // questionId -> answerId
  quizContent: QuizContent | null
  result: LearningStyle | null
  loading: boolean
  error: string | null
}
```

**Best Practices**:
- Create QuizProvider wrapping App
- Custom hook `useQuiz()` for components to access state
- Save answers to localStorage on each selection
- Clear localStorage on quiz restart
- Handle localStorage errors gracefully (private browsing)

### Component Architecture

**Decision**: Page components + smaller UI components

**Structure**:
```
IntroPage (route: /)
  ├─ Button
  └─ Typography

QuestionPage (route: /question/:id)
  ├─ QuizProgress (1/6, 2/6, etc.)
  ├─ QuestionText
  ├─ AnswerOptions
  │   └─ AnswerButton x4
  └─ Navigation (Back/Next buttons)

ResultsPage (route: /result)
  ├─ ResultHeader (learning style name)
  ├─ ResultDescription
  ├─ TipsList
  └─ ActionButtons (Retake, Share, Save)
```

**Best Practices**:
- React Router for page navigation
- Shared components in `/components` folder
- Page-specific components colocated with page
- Props interface for every component
- Atomic design principles (atoms → molecules → organisms → pages)

## Database Schema Patterns

### Quiz Content (Seeded Data)

**Pattern**: Static content loaded via seeds, rarely changes

**Tables**:
- `learning_styles`: 4 rows (Visual, Verbal, Structured, Memorizer)
- `questions`: 6 rows (Q1-Q6)
- `answer_options`: 24 rows (4 per question)

**Best Practices**:
- Use seeds.exs to populate on deployment
- Include seed data in version control
- Schema migrations separate from seed data
- Content changes via new seeds (idempotent inserts)

### Quiz Submissions (Optional Tracking)

**Pattern**: Event sourcing style - immutable submission records

**Best Practices**:
- UUID primary keys (better for partitioning later)
- Store complete snapshot (answers + result + timestamp)
- JSONB for flexible metadata (browser info, referrer, etc.)
- Indexes on created_at for analytics queries
- No updates, only inserts (append-only)

## Testing Strategy

### Backend Testing

**Unit Tests** (ExUnit + DataCase):
- Quiz context functions (get_questions, calculate_result, etc.)
- Learning style tie-breaking logic
- Changesets validation

**Contract Tests** (ConnCase):
- GET /api/v1/quiz/content returns 200 + correct structure
- POST /api/v1/quiz/submissions validates required fields
- CORS headers present on all endpoints

**Coverage Goal**: 80%+

### Frontend Testing

**Component Tests** (Vitest + React Testing Library):
- IntroPage renders and Start button works
- QuestionPage displays question/answers
- Answer selection updates state
- Navigation between questions
- ResultsPage shows correct learning style

**Integration Tests** (Playwright or Cypress):
- Complete quiz flow: intro → all 6 questions → result
- Back/forward navigation preserves answers
- Refresh preserves progress (localStorage)
- Retake quiz clears state

**Coverage Goal**: 70%+ (lower for UI, higher for logic)

## Performance Optimization

### Frontend Optimization

**Strategies**:
- Code splitting: Lazy load pages (React.lazy)
- Bundle size: Tree shaking, minimize dependencies
- Asset optimization: Vite minification, image compression
- Font loading: System fonts or preload Google Fonts
- Analytics: Load GA async (doesn't block render)

**Targets**:
- Initial JS bundle: <100KB gzipped
- Time to Interactive: <2s on 3G
- Lighthouse score: 90+ performance

### Backend Optimization

**Strategies**:
- Connection pooling: Configure for Neon limits (10-20 connections)
- Query optimization: Preload associations, avoid N+1
- Response caching: Cache quiz content (rarely changes)
- CDN: Serve static assets from CDN (CloudFlare or similar)

**Targets**:
- API response: <100ms p95
- Database queries: <20ms p95

## Security Considerations

**CORS Configuration**:
- Production: Allow quiz.margaretsalty.com only
- Development: Allow localhost:5173
- No credentials needed (public API)

**Rate Limiting**:
- Prevent spam submissions
- Use Phoenix rate limiter or Fly.io edge limits
- Limit: 10 submissions per IP per hour

**Data Privacy**:
- No PII required for P1 (just quiz answers)
- If P3 email capture: GDPR compliance, privacy policy
- No sensitive data, minimal storage

**Input Validation**:
- Validate answer IDs exist in database
- Sanitize any text inputs (P3 email)
- Ecto changesets for server-side validation

## Deployment Strategy

### Multi-Stage Docker Build

```dockerfile
# Stage 1: Build React app
FROM node:18 AS frontend-build
WORKDIR /app/assets/quiz
COPY assets/quiz/package*.json ./
RUN npm ci
COPY assets/quiz ./
RUN npm run build

# Stage 2: Build Phoenix release
FROM hexpm/elixir:1.15-erlang-26-alpine AS backend-build
# ... Phoenix build steps ...
# Copy React build artifacts
COPY --from=frontend-build /app/assets/quiz/dist ./priv/static/quiz

# Stage 3: Runtime
FROM alpine:3.18
# ... Runtime setup ...
```

**Benefits**:
- Single artifact contains both frontend + backend
- Optimized layer caching
- Smaller final image

### Environment Variables

**Required**:
- `DATABASE_URL`: Neon connection string
- `SECRET_KEY_BASE`: Phoenix secret
- `GA_TRACKING_ID`: Google Analytics measurement ID
- `PHX_HOST`: quiz.margaretsalty.com

**Configuration**:
- Fly.io secrets for sensitive values
- Runtime.exs for dynamic config
- .env.example for local development

## Development Workflow

### Local Development

**Setup**:
1. Clone repo, checkout branch `001-learning-style-quiz`
2. Set up Neon database (or local Postgres for dev)
3. Install dependencies: `mix deps.get && cd assets/quiz && npm install`
4. Run migrations: `mix ecto.setup`
5. Start Phoenix: `mix phx.server` (backend on :4000)
6. Start Vite dev server: `cd assets/quiz && npm run dev` (frontend on :5173)

**Development Flow**:
- Backend changes: Edit contexts, controllers, auto-reload
- Frontend changes: Edit React components, HMR updates instantly
- Database changes: Create migrations, run `mix ecto.migrate`
- API testing: Use Postman/Insomnia or curl

**Testing**:
- Backend: `mix test` (watch mode: `mix test.watch`)
- Frontend: `cd assets/quiz && npm test`
- E2E: `npm run test:e2e` (after both servers running)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Neon free tier limits hit | Medium | Monitor usage, upgrade plan if needed ($19/mo) |
| React bundle too large | High | Code splitting, lazy loading, minimal dependencies |
| CORS issues in production | High | Test CORS thoroughly in staging, document config |
| GA tracking not firing | Medium | GA DebugView testing, fallback to server-side tracking |
| Fly.io cold starts | Low | Keep app warm with health checks, acceptable for lead gen |
| Quiz content changes frequently | Low | Seed scripts make updates easy, can add CMS later |

## Future Enhancements (Post-MVP)

**Phase 2+ Considerations**:
- Admin panel to edit quiz questions (Phoenix LiveView dashboard)
- Email capture integration (Mailchimp, ConvertKit API)
- Social sharing with Open Graph meta tags
- PDF export of results
- Multiple quizzes (different topics)
- A/B testing framework for question variations
- Advanced analytics dashboard

**Technical Debt to Monitor**:
- If quiz content changes often, consider CMS
- If traffic scales >10k/day, consider CDN for API
- If team grows, split frontend into separate repo
