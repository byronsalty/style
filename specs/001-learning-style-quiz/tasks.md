# Tasks: Learning Style Quiz

**Input**: Design documents from `/specs/001-learning-style-quiz/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/quiz-api.yaml, research.md, quickstart.md

**Organization**: Single user story (complete quiz and get result) - simplified personality quiz with no retake or sharing features.

## Format: `- [ ] [ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Backend**: `lib/style/` (contexts), `lib/style_web/` (web layer)
- **Frontend**: `assets/quiz/src/` (React app)
- **Migrations**: `priv/repo/migrations/`
- **Seeds**: `priv/repo/seeds/`
- **Tests Backend**: `test/style/`, `test/style_web/`
- **Tests Frontend**: `assets/quiz/src/__tests__/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure for both Phoenix backend and React frontend

- [X] T001 [P] Create Phoenix backend structure: Quiz context in lib/style/quiz/
- [X] T002 [P] Create React app structure in assets/quiz/ with Vite, TypeScript, React Router
- [X] T003 [P] Configure PostgreSQL connection for Neon in config/dev.exs and config/prod.exs
- [X] T004 [P] Set up CORS configuration in lib/style_web/endpoint.ex for localhost:5173 and quiz.margaretsalty.com
- [X] T005 [P] Configure environment variables: DATABASE_URL, SECRET_KEY_BASE, GA_TRACKING_ID, PHX_HOST in .env.example
- [X] T006 [P] Install frontend dependencies: React 18, React Router, Axios, TypeScript in assets/quiz/package.json
- [X] T007 [P] Configure Vite build tool in assets/quiz/vite.config.ts
- [X] T008 [P] Set up ESLint and Prettier for frontend in assets/quiz/
- [X] T009 [P] Configure mix format and Credo for backend

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core database schema, migrations, and API infrastructure that MUST be complete before user story implementation

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T010 Create migration: learning_styles table in priv/repo/migrations/*_create_learning_styles.exs
- [X] T011 Create migration: questions table in priv/repo/migrations/*_create_questions.exs
- [X] T012 Create migration: answer_options table in priv/repo/migrations/*_create_answer_options.exs
- [X] T013 [P] Create LearningStyle schema in lib/style/quiz/learning_style.ex
- [X] T014 [P] Create Question schema in lib/style/quiz/question.ex
- [X] T015 [P] Create AnswerOption schema in lib/style/quiz/answer_option.ex
- [X] T016 Create Quiz context module in lib/style/quiz.ex with get_quiz_content/0 function
- [X] T017 Create seed file for quiz content in priv/repo/seeds/quiz_content.exs (4 learning styles, 6 questions, 24 answers)
- [X] T018 Run migrations and seeds: mix ecto.migrate && mix run priv/repo/seeds/quiz_content.exs
- [X] T019 Create API routes in lib/style_web/router.ex: GET /api/v1/quiz/content, GET /health
- [X] T020 Create QuizController in lib/style_web/controllers/quiz_controller.ex with action stubs
- [X] T021 [P] Create TypeScript types in assets/quiz/src/types/quiz.ts: Question, AnswerOption, LearningStyle, QuizContent
- [X] T022 [P] Create API client service in assets/quiz/src/services/api.ts for Phoenix backend communication
- [X] T023 [P] Set up React Router in assets/quiz/src/App.tsx with routes: /, /question/:id, /result

**Checkpoint**: ✅ Foundation ready - user story implementation can now begin

---

## Phase 3: Complete Quiz and Discover Learning Style 🎯 MVP

**Goal**: User can navigate from intro page through all 6 questions and receive a personalized learning style result with actionable study tips.

**Independent Test**: Complete quiz flow from intro → 6 questions → result page with correct learning style calculation and tips display.

### Backend Implementation

- [ ] T024 Implement Quiz.get_quiz_content/0 in lib/style/quiz.ex to fetch all questions with preloaded answer_options and learning_styles
- [ ] T025 Implement QuizController.content/2 action in lib/style_web/controllers/quiz_controller.ex to return JSON quiz content
- [ ] T026 Implement Quiz.calculate_result/1 in lib/style/quiz.ex to determine learning style from answer IDs with tie-breaking logic (Visual > Verbal > Structured > Memorizer)
- [ ] T027 Add validation helper in lib/style/quiz.ex to verify all 6 questions answered and answer IDs are valid

### Frontend Implementation

- [ ] T028 [P] Create IntroPage component in assets/quiz/src/components/IntroPage.tsx with quiz title "What's Your Study Style?" and Start button
- [ ] T029 [P] Create QuestionPage component in assets/quiz/src/components/QuestionPage.tsx to display question and 4 answer options
- [ ] T030 [P] Create ResultsPage component in assets/quiz/src/components/ResultsPage.tsx to show learning style name, description, and tips
- [ ] T031 [P] Create QuizProgress component in assets/quiz/src/components/QuizProgress.tsx to show "Question X of 6"
- [ ] T032 [P] Create AnswerButton component in assets/quiz/src/components/AnswerButton.tsx for answer selection UI
- [ ] T033 Create useQuiz hook in assets/quiz/src/hooks/useQuiz.ts for state management: currentQuestion, answers, quizContent, result
- [ ] T034 Implement localStorage persistence in useQuiz hook to save/restore quiz progress on page refresh
- [ ] T035 Implement client-side result calculation in useQuiz hook: count learning style frequency and apply tie-breaking
- [ ] T036 Wire up IntroPage to fetch quiz content from API and navigate to first question
- [ ] T037 Wire up QuestionPage navigation: save answer, move to next/previous question
- [ ] T038 Wire up submit logic: validate all 6 answers, calculate result, navigate to ResultsPage
- [ ] T039 Add answer selection highlighting and validation (prevent submit until all answered)

**Checkpoint**: User can complete quiz and see personalized result

---

## Phase 4: Analytics Integration

**Purpose**: Google Analytics 4 tracking for lead generation metrics

- [ ] T040 [P] Add Google Analytics script tag to assets/quiz/public/index.html with GA_TRACKING_ID placeholder
- [ ] T041 [P] Create useAnalytics hook in assets/quiz/src/hooks/useAnalytics.ts to centralize GA event tracking
- [ ] T042 Track quiz_started event when user clicks "Start Quiz" on IntroPage
- [ ] T043 Track question_answered events as user progresses through quiz
- [ ] T044 Track quiz_completed event with learning_style result when user reaches ResultsPage

---

## Phase 5: Polish & Deployment

**Purpose**: Production readiness, styling, testing, and deployment configuration

- [ ] T045 [P] Add loading states to all API calls in frontend components
- [ ] T046 [P] Add error handling and error messages for API failures
- [ ] T047 [P] Make quiz mobile-responsive (375px min width) with CSS media queries
- [ ] T048 [P] Add basic styling and branding to all quiz pages (colors, fonts, layout)
- [ ] T049 [P] Implement accessibility: keyboard navigation, ARIA labels, focus management
- [ ] T050 [P] Add backend API contract tests in test/style_web/controllers/quiz_controller_test.exs
- [ ] T051 [P] Add frontend component tests in assets/quiz/src/__tests__/ for IntroPage, QuestionPage, ResultsPage
- [ ] T052 Create Dockerfile with multi-stage build: React build → Phoenix release → runtime
- [ ] T053 Create fly.toml for Fly.io deployment configuration
- [ ] T054 [P] Add health check endpoint implementation in lib/style_web/controllers/quiz_controller.ex
- [ ] T055 Validate quickstart.md setup instructions by following them in fresh environment
- [ ] T056 [P] Run mix format and mix credo --strict on all Elixir code
- [ ] T057 [P] Run npm run lint and npm run format on all frontend code
- [ ] T058 Test complete user journey end-to-end: intro → all 6 questions → result

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS quiz implementation
- **Quiz Implementation (Phase 3)**: Depends on Foundational (Phase 2)
- **Analytics (Phase 4)**: Depends on Phase 3 being functional (needs quiz flow to track)
- **Polish (Phase 5)**: Depends on Phase 3 being complete (needs working quiz to polish)

### Sequential Flow Within Quiz Implementation

**Backend (Sequential)**:
1. Migrations (T010-T012)
2. Schemas (T013-T015) - can be parallel after migrations
3. Context module (T016)
4. Seeds (T017-T018)
5. Routes and controller (T019-T020)
6. Implementation (T024-T027)

**Frontend (After Backend API ready)**:
1. Types and API client (T021-T023) - parallel
2. Components (T028-T032) - all parallel
3. Hooks (T033-T035) - sequential
4. Wire-up (T036-T039) - sequential

### Parallel Opportunities

**Phase 1 (Setup)**: All 9 tasks marked [P] can run in parallel (different configuration files)

**Phase 2 (Foundational)**:
- After migrations run: All 3 schema tasks (T013-T015) can run in parallel
- Frontend types and API client (T021-T023) can run in parallel

**Phase 3 (Quiz Implementation)**:
- All 5 UI components (T028-T032) can run in parallel

**Phase 4 (Analytics)**: Hook creation and script tag (T040-T041) can run in parallel

**Phase 5 (Polish)**: Most polish tasks can run in parallel - styling, testing, accessibility, linting all independent

---

## Parallel Example: Frontend Components

```bash
# Launch all UI components together:
Task: "Create IntroPage component in assets/quiz/src/components/IntroPage.tsx"
Task: "Create QuestionPage component in assets/quiz/src/components/QuestionPage.tsx"
Task: "Create ResultsPage component in assets/quiz/src/components/ResultsPage.tsx"
Task: "Create QuizProgress component in assets/quiz/src/components/QuizProgress.tsx"
Task: "Create AnswerButton component in assets/quiz/src/components/AnswerButton.tsx"
```

## Parallel Example: Backend Schemas

```bash
# Launch all schema definitions together after migrations:
Task: "Create LearningStyle schema in lib/style/quiz/learning_style.ex"
Task: "Create Question schema in lib/style/quiz/question.ex"
Task: "Create AnswerOption schema in lib/style/quiz/answer_option.ex"
```

---

## Implementation Strategy

### MVP Approach (All Phases)

1. Complete Phase 1: Setup (9 tasks)
2. Complete Phase 2: Foundational (14 tasks) - CRITICAL CHECKPOINT
3. Complete Phase 3: Quiz Implementation (16 tasks)
4. Complete Phase 4: Analytics (5 tasks)
5. Complete Phase 5: Polish (14 tasks)
6. **STOP and VALIDATE**: Test complete quiz flow end-to-end
7. Deploy to Fly.io with custom domain quiz.margaretsalty.com

**Total MVP Tasks**: 58 tasks

### Development Flow

**Week 1**: Setup + Foundational
- Day 1-2: Phase 1 (Setup)
- Day 3-5: Phase 2 (Foundational)
- Checkpoint: API returns quiz content successfully

**Week 2**: Core Quiz Implementation
- Day 1-2: Backend implementation (T024-T027)
- Day 3-5: Frontend components and hooks (T028-T039)
- Checkpoint: Can complete quiz and see result

**Week 3**: Analytics + Polish
- Day 1: Analytics integration (T040-T044)
- Day 2-5: Polish and testing (T045-T058)
- Checkpoint: Production-ready quiz

### Parallel Team Strategy

With 2 developers:
1. Both complete Setup together (Phase 1)
2. Both complete Foundational together (Phase 2) - CHECKPOINT
3. Split Quiz Implementation:
   - Developer A: Backend tasks (T024-T027)
   - Developer B: Frontend components (T028-T032)
4. Developer B continues with hooks and wire-up (T033-T039)
5. Developer A: Analytics integration (Phase 4)
6. Both: Polish and testing (Phase 5)

---

## Task Summary

**Total Tasks**: 58 tasks

**By Phase**:
- Phase 1 (Setup): 9 tasks
- Phase 2 (Foundational): 14 tasks
- Phase 3 (Quiz Implementation): 16 tasks
- Phase 4 (Analytics): 5 tasks
- Phase 5 (Polish): 14 tasks

**By Category**:
- Backend: 18 tasks
- Frontend: 25 tasks
- Infrastructure: 9 tasks (setup)
- Cross-cutting: 6 tasks (analytics + polish)

**Parallel Opportunities**: 36 tasks marked [P] can run in parallel with other tasks

---

## Notes

- [P] tasks = different files, no dependencies, can run in parallel
- Simple personality quiz - user completes once and sees their result
- No retake feature (personality quiz doesn't need retaking)
- No sharing feature (results displayed immediately, not persisted)
- Result calculated client-side for immediate feedback
- No backend submission persistence needed (stateless quiz)
- localStorage preserves progress during refresh but cleared after completion
- Commit after each task or logical group
- Backend uses Phoenix 1.8.1 + Elixir 1.15+, Frontend uses React 18 + TypeScript + Vite
- Database: PostgreSQL via Neon (only for quiz content, not submissions)
- Deployment: Fly.io with custom domain quiz.margaretsalty.com
- All file paths follow project structure from plan.md
