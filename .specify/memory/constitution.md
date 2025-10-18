<!--
SYNC IMPACT REPORT - Constitution Update

Version Change: [INITIAL] → 1.0.0
Rationale: Initial constitution establishment for Style project (Phoenix/Elixir web application).
  This is a MAJOR version as it establishes the foundational governance framework.

Modified Principles: N/A (initial creation)
Added Sections:
  - Core Principles (I-V): Phoenix Patterns, LiveView First, Context Boundaries,
    Test-Driven Development, Database Integrity
  - Development Standards: Code quality, testing requirements, performance expectations
  - Workflow & Quality Gates: Feature workflow, review requirements, deployment gates

Templates Status:
  ✅ plan-template.md - Constitution Check section aligns (line 30-34)
  ✅ spec-template.md - User scenarios and requirements structure compatible
  ✅ tasks-template.md - Phase structure and testing gates compatible
  ✅ No command templates present to update

Follow-up TODOs: None - all placeholders filled
-->

# Style Constitution

## Core Principles

### I. Phoenix Patterns

The Style project MUST adhere to Phoenix framework conventions and best practices:

- Follow Phoenix directory structure: contexts in `lib/style/`, web layer in `lib/style_web/`
- Use Phoenix generators (`mix phx.gen.*`) as the starting point for new resources
- Leverage Phoenix's compilation-time guarantees (no runtime route errors, verified function calls)
- All database access MUST go through Ecto schemas and changesets
- HTTP concerns (controllers, views, templates) stay in the web layer
- Business logic resides in contexts, never in controllers or LiveViews

**Rationale**: Phoenix conventions provide consistency, maintainability, and leverage
framework optimizations. Violating these patterns leads to difficult-to-maintain code
and negates framework benefits.

### II. LiveView First

For interactive UI features, Phoenix LiveView MUST be the default choice:

- Real-time interactivity implemented via LiveView unless proven insufficient
- Traditional request/response only for: public pages, SEO-critical content, or high-scale read-only pages
- LiveView components MUST be isolated, testable, and reusable
- PubSub used for cross-LiveView communication, never direct process messaging
- Client-side JavaScript only when LiveView cannot meet requirements (with justification)

**Rationale**: LiveView provides real-time capabilities with server-rendered HTML,
reducing JavaScript complexity and maintaining type safety across the stack.

### III. Context Boundaries (NON-NEGOTIABLE)

Business logic MUST be organized into well-defined Ecto contexts:

- Each context represents a bounded domain (e.g., `Accounts`, `Content`, `Analytics`)
- Contexts expose clear public APIs; internal functions are private
- Cross-context communication only through public context functions
- Database schemas belong to their owning context and are not shared
- Data needed by multiple contexts is fetched via context APIs, not by direct schema access
- No context may directly access another context's database tables

**Rationale**: Context boundaries prevent tight coupling, enable independent testing,
and make the codebase navigable. This is Phoenix's answer to domain-driven design.

### IV. Test-Driven Development

Testing is mandatory and follows Phoenix testing best practices:

- **Unit tests**: All context functions MUST have unit tests using `DataCase`
- **Integration tests**: LiveView interactions and multi-context workflows tested with `ConnCase`
- **Contract tests**: External API boundaries (controllers, channels) have contract tests
- Tests run in isolation with `Ecto.Adapters.SQL.Sandbox`
- Factories (via ExMachina or similar) preferred over fixtures for test data
- Tests MUST pass before merging; `mix test` runs in CI

**Test-First Workflow** (when specified):
1. Write failing test for new functionality
2. Get user/reviewer approval of test scenarios
3. Implement feature until tests pass
4. Refactor while keeping tests green

**Rationale**: Elixir's pattern matching and immutability make tests reliable and fast.
TDD catches issues early and serves as living documentation.

### V. Database Integrity

Database design MUST prioritize data integrity and leverage PostgreSQL features:

- All tables MUST have primary keys (preferably UUIDs for distributed systems)
- Foreign keys enforced at database level with proper `references` in migrations
- Use database constraints (unique, not null, check) to enforce business rules
- Migrations MUST be reversible (implement `down` for all `up` changes)
- Index strategy defined for query patterns; explain analyze before optimizing
- No schema changes in production without migration review and rollback plan

**Rationale**: PostgreSQL is a powerful relational database. Using constraints and
foreign keys prevents invalid states and makes debugging easier. Ecto makes this safe.

## Development Standards

### Code Quality

- All code formatted with `mix format` (enforced in pre-commit)
- Compiler warnings treated as errors in CI (`mix compile --warnings-as-errors`)
- Credo used for additional linting (run `mix credo --strict`)
- Dialyzer for type checking (gradual adoption via `dialyxir`)
- Code review required for all changes; no direct commits to main
- Maximum function complexity: 15 lines (guideline, not hard rule)

### Testing Requirements

- Minimum test coverage: 80% (measured via `mix test --cover`)
- All public context functions MUST be tested
- LiveView rendering and event handling MUST be tested
- Critical paths (authentication, payments, data mutations) require integration tests
- Tests MUST run in under 30 seconds for rapid feedback

### Performance Expectations

- Page loads: Target <200ms for server-rendered pages (p95)
- LiveView mounts: Target <100ms for initial render (p95)
- Database queries: N+1 queries are bugs; use `Repo.preload` or joins
- No synchronous external API calls in request path; use async tasks or queues
- Connection pool sizing: `pool_size` based on database connection limits

## Workflow & Quality Gates

### Feature Workflow

All new features MUST follow the SpecKit workflow:

1. **Specification**: Create feature spec via `/speckit.specify` (user scenarios, requirements)
2. **Planning**: Generate implementation plan via `/speckit.plan` (design, contracts, data model)
3. **Task Generation**: Generate dependency-ordered tasks via `/speckit.tasks`
4. **Implementation**: Execute tasks via `/speckit.implement` or manually
5. **Review**: Code review, test validation, constitution compliance check

### Constitution Compliance

Before merging, verify:

- [ ] Phoenix patterns followed (contexts, web layer separation)
- [ ] LiveView used for interactive features (or justified alternative)
- [ ] Context boundaries respected (no cross-context schema access)
- [ ] Tests written and passing (coverage ≥80%)
- [ ] Database migrations reversible with integrity constraints
- [ ] Code formatted and linted (warnings-as-errors)

### Deployment Gates

Production deployments require:

- All tests passing (`mix test`)
- No compiler warnings
- Database migrations reviewed and tested on staging
- Rollback plan documented for schema changes
- Performance regression testing for critical paths

## Governance

This constitution supersedes all informal practices and establishes the binding
framework for Style project development.

**Amendment Process**:
- Amendments require documentation of rationale and impact analysis
- Breaking changes to principles require MAJOR version bump
- New principles or expanded guidance require MINOR version bump
- Clarifications and corrections require PATCH version bump
- All amendments MUST update dependent templates (spec, plan, tasks)

**Compliance Review**:
- All pull requests MUST verify constitution compliance
- Violations require explicit justification or principle amendment
- Complexity not aligned with principles must be justified in plan.md Complexity Tracking table

**Runtime Guidance**:
Development agents and team members should reference this constitution when making
architectural decisions, conducting code reviews, and planning features.

**Version**: 1.0.0 | **Ratified**: 2025-10-17 | **Last Amended**: 2025-10-17
