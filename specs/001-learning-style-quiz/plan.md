# Implementation Plan: Learning Style Quiz

**Branch**: `001-learning-style-quiz` | **Date**: 2025-10-17 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-learning-style-quiz/spec.md`

## Summary

Build a standalone lead-generation quiz application that helps prospective students discover their learning style through 6 multiple-choice questions. The quiz determines one of 4 learning styles (Visual Learner, Verbal Processor, Structured Planner, or Memorizer) and provides personalized study tips. The application will be deployed as a separate service on a custom domain (quiz.margaretsalty.com) to capture leads for online courses.

**Technical Approach**: React SPA frontend + Phoenix JSON API backend, deployed to Fly.io with Neon PostgreSQL database. Google Analytics integration for conversion tracking. Results calculated client-side for immediate feedback, with optional backend persistence for lead capture and analytics.

## Technical Context

**Language/Version**: Elixir 1.15+ / Phoenix 1.8.1 (backend), React 18+ with TypeScript (frontend)
**Primary Dependencies**:
- Backend: Phoenix 1.8.1, Ecto 3.13, Postgrex, CORS plug, Jason (JSON)
- Frontend: React 18, React Router, Axios/Fetch API, Vite build tool
- Analytics: Google Analytics 4 (gtag.js)

**Storage**: PostgreSQL via Neon (serverless Postgres)
- Quiz content (questions, answers, learning styles) - seeded data
- Quiz submissions (optional, for lead tracking and analytics)
- User contact info (if P3 lead capture implemented)

**Testing**:
- Backend: ExUnit with Phoenix.ConnCase for API tests
- Frontend: Vitest + React Testing Library for component tests
- E2E: Playwright or Cypress for critical user flows

**Target Platform**: Web (Chrome, Safari, Firefox, Edge - modern browsers), Mobile responsive (iOS Safari, Chrome Mobile)

**Project Type**: Web application with separated frontend/backend

**Performance Goals**:
- Initial page load: <1.5s (incl. React bundle)
- API response time: <100ms p95
- Quiz navigation: instant (<50ms)
- Result calculation: <100ms

**Constraints**:
- Must work on mobile (375px min width)
- No authentication required (public quiz)
- Deployable to Fly.io (containerized)
- Neon free tier compatible (limit DB connections)
- Google Analytics integration mandatory
- Custom domain quiz.margaretsalty.com

**Scale/Scope**:
- Expected traffic: 100-1000 quiz submissions/day initially
- Lead gen conversion goal: 20-30% email capture rate (P3)
- 6 questions, 4 answer options each, 4 result types
- Single-page app experience (3 views: intro, questions, results)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Phoenix Patterns
- ✅ **COMPLIANT**: Backend follows Phoenix conventions
  - Contexts: `Quiz` context for quiz logic, `Analytics` context for tracking
  - Web layer: JSON API controllers in `StyleWeb.QuizController`
  - Database access through Ecto schemas and changesets
  - Business logic in contexts, not controllers

### Principle II: LiveView First
- ⚠️ **VIOLATION**: Using React SPA instead of LiveView
  - **Justification**: See Complexity Tracking table below
  - Alternative considered: LiveView was evaluated but rejected for this use case

### Principle III: Context Boundaries
- ✅ **COMPLIANT**: Clear context separation planned
  - `Quiz` context: Quiz content, submissions, result calculation
  - `Analytics` context: Tracking, metrics, lead capture
  - Cross-context communication through public APIs only

### Principle IV: Test-Driven Development
- ✅ **COMPLIANT**: Testing strategy defined
  - Backend: API contract tests for all endpoints
  - Frontend: Component tests for quiz flow
  - Integration tests for lead capture workflow (if P3 implemented)
  - Minimum 80% coverage target

### Principle V: Database Integrity
- ✅ **COMPLIANT**: PostgreSQL with full integrity constraints
  - Primary keys (UUIDs for submissions)
  - Foreign keys for answer → question relationships
  - NOT NULL constraints on required fields
  - Check constraints for valid enum values (learning_style)
  - Migrations fully reversible

### Development Standards
- ✅ Code Quality: `mix format`, warnings as errors, Credo linting
- ✅ Testing: 80% coverage, API contract tests
- ✅ Performance: <100ms API responses, <200ms page loads

### Deployment Gates
- ✅ Fly.io deployment config (`fly.toml`)
- ✅ Neon database connection pooling configured
- ✅ Google Analytics tracking verified
- ✅ Custom domain DNS configured

**Gate Status**: ⚠️ **CONDITIONAL PASS** - Requires justification for React usage (see Complexity Tracking)

## Project Structure

### Documentation (this feature)

```
specs/001-learning-style-quiz/
├── plan.md              # This file
├── research.md          # Technology decisions and patterns
├── data-model.md        # Database schema and entities
├── quickstart.md        # Local development guide
├── contracts/           # API specifications
│   └── quiz-api.yaml    # OpenAPI spec for quiz endpoints
└── checklists/
    └── requirements.md  # Quality validation checklist
```

### Source Code (repository root)

```
# Backend: Phoenix API
lib/style/
├── quiz/                      # Quiz context
│   ├── question.ex           # Question schema
│   ├── answer_option.ex      # Answer option schema
│   ├── learning_style.ex     # Learning style schema
│   ├── submission.ex         # Quiz submission schema (optional)
│   └── quiz.ex               # Context API
└── analytics/                # Analytics context (future)
    └── analytics.ex          # Tracking context API

lib/style_web/
├── controllers/
│   └── quiz_controller.ex    # JSON API endpoints
└── router.ex                 # API routes with CORS

priv/repo/migrations/
├── *_create_questions.exs
├── *_create_answer_options.exs
├── *_create_learning_styles.exs
└── *_create_submissions.exs

priv/repo/seeds/
└── quiz_content.exs          # Seed 6 questions + 4 learning styles

test/style/quiz_test.exs      # Context tests
test/style_web/controllers/
└── quiz_controller_test.exs  # API contract tests

# Frontend: React SPA
assets/quiz/                  # Separate React app
├── src/
│   ├── components/
│   │   ├── IntroPage.tsx
│   │   ├── QuestionPage.tsx
│   │   ├── ResultsPage.tsx
│   │   ├── QuizProgress.tsx
│   │   └── Navigation.tsx
│   ├── hooks/
│   │   ├── useQuiz.ts        # Quiz state management
│   │   └── useAnalytics.ts   # GA tracking
│   ├── services/
│   │   └── api.ts            # Phoenix API client
│   ├── types/
│   │   └── quiz.ts           # TypeScript interfaces
│   ├── App.tsx
│   └── main.tsx
├── public/
│   └── index.html            # GA script tag
├── package.json
├── vite.config.ts
└── tsconfig.json

# Deployment
fly.toml                      # Fly.io config
Dockerfile                    # Multi-stage: backend + static frontend
.env.example                  # Neon DB URL, GA tracking ID
```

**Structure Decision**: **Web application (Option 2)** - React frontend as a separate SPA in `assets/quiz/`, Phoenix backend provides JSON API. Frontend builds to static files served by Phoenix or CDN. This structure enables:
- Independent frontend/backend deployment
- Static asset optimization and CDN hosting
- Clear separation of concerns
- Frontend can be extracted to separate repo later if needed

## Complexity Tracking

*Constitution Principle II violations requiring justification*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| React SPA instead of LiveView | 1. **Separate domain/standalone app**: Deployed to quiz.margaretsalty.com as isolated lead-gen tool, not part of main Style app<br>2. **Static hosting/CDN potential**: React app can be built to static files and served via CDN for global performance<br>3. **Lead gen optimization**: Marketing team needs ability to A/B test, iterate rapidly, and integrate with marketing tools (GA, Facebook Pixel, email capture widgets) without Phoenix knowledge<br>4. **Embeddability**: React component can be embedded in other marketing sites/landing pages<br>5. **Resume/state management**: Client-side state allows users to refresh without losing quiz progress (localStorage)<br>6. **Portfolio/learning opportunity**: Demonstrates React + Phoenix API integration pattern for future projects | LiveView would work technically but:<br>- Requires Phoenix knowledge for marketing team iterations<br>- WebSocket overhead for simple quiz (no real-time features needed)<br>- Cannot be easily embedded in external sites<br>- Harder to deploy to CDN for performance<br>- localStorage state management simpler than LiveView session<br>- Lead gen tools (Facebook Pixel, Google Tag Manager) easier to integrate in SPA |
