# Data Model: Learning Style Quiz

**Date**: 2025-10-17
**Feature**: Learning Style Quiz (001-learning-style-quiz)
**Database**: PostgreSQL via Neon

## Overview

The quiz data model consists of static content (questions, answers, learning styles) and optional dynamic data (quiz submissions for analytics). Content is seeded once and rarely changes. Submissions are append-only for tracking.

## Entity Relationship Diagram

```
┌─────────────────┐
│ learning_styles │
│ (4 records)     │
└────────┬────────┘
         │
         │ referenced by
         │
┌────────┴────────┐         ┌──────────────┐
│  answer_options │◄────────│  questions   │
│  (24 records)   │ belongs │  (6 records) │
└─────────────────┘   to    └──────────────┘
         │
         │ referenced in
         │
┌────────┴────────┐
│   submissions   │
│   (optional)    │
└─────────────────┘
```

## Entities

### 1. learning_styles

**Purpose**: Defines the 4 quiz result types with descriptions and study tips

**Table**: `learning_styles`

| Column      | Type         | Constraints           | Description                                    |
|-------------|--------------|-----------------------|------------------------------------------------|
| id          | uuid         | PRIMARY KEY           | Unique identifier                              |
| name        | varchar(50)  | NOT NULL, UNIQUE      | Learning style name (e.g., "Visual Learner")   |
| slug        | varchar(50)  | NOT NULL, UNIQUE      | URL-friendly key (e.g., "visual-learner")      |
| description | text         | NOT NULL              | Short description of the learning style        |
| tips        | jsonb        | NOT NULL              | Array of study tips (2-3 items)                |
| created_at  | timestamptz  | NOT NULL DEFAULT NOW  | Record creation time                           |
| updated_at  | timestamptz  | NOT NULL DEFAULT NOW  | Record update time                             |

**Indexes**:
- PRIMARY KEY on `id`
- UNIQUE INDEX on `slug` (for URL-friendly lookups)

**Sample Data**:
```elixir
%{
  id: "uuid-1",
  name: "Visual Learner",
  slug: "visual-learner",
  description: "Loves diagrams, color-coded notes, and video content.",
  tips: [
    "Use our video modules and domain one-pagers to map it out",
    "Create visual aids like mind maps and flowcharts",
    "Color-code your notes by topic or concept"
  ]
}
```

**Validation Rules**:
- `name`: Required, 3-50 characters, unique
- `slug`: Required, lowercase, alphanumeric + hyphens only
- `description`: Required, 10-500 characters
- `tips`: Required, must be array with 2-3 strings, each 10-200 chars

### 2. questions

**Purpose**: Stores the 6 quiz questions

**Table**: `questions`

| Column      | Type         | Constraints           | Description                                    |
|-------------|--------------|-----------------------|------------------------------------------------|
| id          | uuid         | PRIMARY KEY           | Unique identifier                              |
| position    | integer      | NOT NULL, UNIQUE      | Question order (1-6)                           |
| text        | text         | NOT NULL              | Question text displayed to user                |
| created_at  | timestamptz  | NOT NULL DEFAULT NOW  | Record creation time                           |
| updated_at  | timestamptz  | NOT NULL DEFAULT NOW  | Record update time                             |

**Indexes**:
- PRIMARY KEY on `id`
- INDEX on `position` (for ordering)

**Check Constraints**:
- `position >= 1 AND position <= 6`

**Sample Data**:
```elixir
%{
  id: "uuid-q1",
  position: 1,
  text: "When you sit down to study, what helps you focus most?"
}
```

**Validation Rules**:
- `position`: Required, integer 1-6, unique
- `text`: Required, 10-500 characters

### 3. answer_options

**Purpose**: Stores the 4 answer choices for each question, mapped to learning styles

**Table**: `answer_options`

| Column             | Type         | Constraints                       | Description                                    |
|--------------------|--------------|-----------------------------------|------------------------------------------------|
| id                 | uuid         | PRIMARY KEY                       | Unique identifier                              |
| question_id        | uuid         | NOT NULL, FOREIGN KEY → questions | Question this answer belongs to                |
| learning_style_id  | uuid         | NOT NULL, FOREIGN KEY → learning_styles | Learning style this answer maps to     |
| label              | varchar(1)   | NOT NULL                          | Answer label (A, B, C, or D)                   |
| text               | text         | NOT NULL                          | Answer text displayed to user                  |
| created_at         | timestamptz  | NOT NULL DEFAULT NOW              | Record creation time                           |
| updated_at         | timestamptz  | NOT NULL DEFAULT NOW              | Record update time                             |

**Indexes**:
- PRIMARY KEY on `id`
- INDEX on `question_id` (for fetching question's answers)
- INDEX on `learning_style_id` (for analytics)

**Foreign Keys**:
- `question_id` REFERENCES `questions(id)` ON DELETE CASCADE
- `learning_style_id` REFERENCES `learning_styles(id)` ON DELETE RESTRICT

**Check Constraints**:
- `label IN ('A', 'B', 'C', 'D')`

**Unique Constraint**:
- UNIQUE(`question_id`, `label`) - each question has exactly one A, B, C, D

**Sample Data**:
```elixir
%{
  id: "uuid-a1",
  question_id: "uuid-q1",
  learning_style_id: "uuid-visual",
  label: "A",
  text: "Watching videos or tutorials"
}
```

**Validation Rules**:
- `question_id`: Required, must exist in questions table
- `learning_style_id`: Required, must exist in learning_styles table
- `label`: Required, must be 'A', 'B', 'C', or 'D'
- `text`: Required, 5-300 characters
- Unique combination of `question_id` + `label`

### 4. submissions (Optional - for analytics)

**Purpose**: Track quiz completions for analytics and lead generation

**Table**: `submissions`

| Column             | Type         | Constraints           | Description                                    |
|--------------------|--------------|-----------------------|------------------------------------------------|
| id                 | uuid         | PRIMARY KEY           | Unique identifier (shareable link ID)          |
| learning_style_id  | uuid         | NOT NULL, FOREIGN KEY → learning_styles | Result learning style                  |
| answers            | jsonb        | NOT NULL              | Complete answer selection (question → answer)  |
| metadata           | jsonb        | DEFAULT '{}'          | Browser info, referrer, etc.                   |
| completed_at       | timestamptz  | NOT NULL DEFAULT NOW  | Quiz completion timestamp                      |

**Indexes**:
- PRIMARY KEY on `id`
- INDEX on `learning_style_id` (for result distribution analytics)
- INDEX on `completed_at` (for time-series queries)

**Foreign Keys**:
- `learning_style_id` REFERENCES `learning_styles(id)` ON DELETE RESTRICT

**Sample Data**:
```elixir
%{
  id: "uuid-sub-123",
  learning_style_id: "uuid-visual",
  answers: %{
    "uuid-q1" => "uuid-a1",  # Question 1 → Answer A (Visual)
    "uuid-q2" => "uuid-a5",  # Question 2 → Answer A (Visual)
    "uuid-q3" => "uuid-a9",  # Question 3 → Answer A (Visual)
    "uuid-q4" => "uuid-a13", # Question 4 → Answer A (Visual)
    "uuid-q5" => "uuid-a17", # Question 5 → Answer B (Verbal)
    "uuid-q6" => "uuid-a21"  # Question 6 → Answer A (Visual)
  },
  metadata: %{
    "user_agent" => "Mozilla/5.0...",
    "referrer" => "https://example.com",
    "completion_time_seconds" => 87
  },
  completed_at: ~U[2025-10-17 14:30:00Z]
}
```

**Validation Rules**:
- `learning_style_id`: Required, must exist in learning_styles table
- `answers`: Required, must be object with 6 question_id keys
- `metadata`: Optional object
- `completed_at`: Auto-set to current timestamp

## Database Migrations

### Migration Order

1. `20251017_001_create_learning_styles.exs`
2. `20251017_002_create_questions.exs`
3. `20251017_003_create_answer_options.exs`
4. `20251017_004_create_submissions.exs` (optional, can be added later)

### Migration 1: Create learning_styles

```elixir
defmodule Style.Repo.Migrations.CreateLearningStyles do
  use Ecto.Migration

  def up do
    create table(:learning_styles, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, size: 50, null: false
      add :slug, :string, size: 50, null: false
      add :description, :text, null: false
      add :tips, :jsonb, null: false

      timestamps(type: :timestamptz)
    end

    create unique_index(:learning_styles, [:slug])
    create unique_index(:learning_styles, [:name])
  end

  def down do
    drop table(:learning_styles)
  end
end
```

### Migration 2: Create questions

```elixir
defmodule Style.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def up do
    create table(:questions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :position, :integer, null: false
      add :text, :text, null: false

      timestamps(type: :timestamptz)
    end

    create unique_index(:questions, [:position])
    create constraint(:questions, :valid_position, check: "position >= 1 AND position <= 6")
  end

  def down do
    drop table(:questions)
  end
end
```

### Migration 3: Create answer_options

```elixir
defmodule Style.Repo.Migrations.CreateAnswerOptions do
  use Ecto.Migration

  def up do
    create table(:answer_options, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :question_id, references(:questions, type: :uuid, on_delete: :delete_all), null: false
      add :learning_style_id, references(:learning_styles, type: :uuid, on_delete: :restrict), null: false
      add :label, :string, size: 1, null: false
      add :text, :text, null: false

      timestamps(type: :timestamptz)
    end

    create index(:answer_options, [:question_id])
    create index(:answer_options, [:learning_style_id])
    create unique_index(:answer_options, [:question_id, :label])
    create constraint(:answer_options, :valid_label, check: "label IN ('A', 'B', 'C', 'D')")
  end

  def down do
    drop table(:answer_options)
  end
end
```

### Migration 4: Create submissions (Optional)

```elixir
defmodule Style.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def up do
    create table(:submissions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :learning_style_id, references(:learning_styles, type: :uuid, on_delete: :restrict), null: false
      add :answers, :jsonb, null: false
      add :metadata, :jsonb, default: "{}"
      add :completed_at, :timestamptz, null: false, default: fragment("NOW()")
    end

    create index(:submissions, [:learning_style_id])
    create index(:submissions, [:completed_at])
  end

  def down do
    drop table(:submissions)
  end
end
```

## Seed Data

### File: `priv/repo/seeds/quiz_content.exs`

```elixir
# Idempotent seed script - safe to run multiple times

alias Style.Repo
alias Style.Quiz.{LearningStyle, Question, AnswerOption}

# Seed Learning Styles
learning_styles = [
  %{
    slug: "visual-learner",
    name: "Visual Learner",
    description: "Loves diagrams, color-coded notes, and video content.",
    tips: [
      "Use our video modules and domain one-pagers to map it out",
      "Create visual aids like mind maps and flowcharts",
      "Color-code your notes by topic or concept"
    ]
  },
  %{
    slug: "verbal-processor",
    name: "Verbal Processor",
    description: "Learns by speaking, teaching, and hearing things aloud.",
    tips: [
      "Record yourself summarizing concepts and use audio flashcards",
      "Form study groups and teach concepts to others",
      "Read your notes aloud or discuss topics with peers"
    ]
  },
  %{
    slug: "structured-planner",
    name: "Structured Planner",
    description: "Needs clarity, order, and repeatable systems.",
    tips: [
      "Start with our Pass Prep Planner and make checklists",
      "Break down topics into structured outlines",
      "Create a consistent study schedule and stick to it"
    ]
  },
  %{
    slug: "memorizer",
    name: "Memorizer",
    description: "Repetition, flashcards, and highlighters are your best friends.",
    tips: [
      "Use the Vault's flashcard deck and timed review loops",
      "Practice spaced repetition for better retention",
      "Highlight key concepts and review them regularly"
    ]
  }
]

Enum.each(learning_styles, fn attrs ->
  {:ok, _} = Repo.insert(
    %LearningStyle{id: Ecto.UUID.generate()}
    |> LearningStyle.changeset(attrs),
    on_conflict: :nothing,
    conflict_target: :slug
  )
end)

# ... (similar for questions and answer_options)
```

## Schema Modules

### LearningStyle Schema

```elixir
defmodule Style.Quiz.LearningStyle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "learning_styles" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :tips, {:array, :string}

    has_many :answer_options, Style.Quiz.AnswerOption
    has_many :submissions, Style.Quiz.Submission

    timestamps(type: :utc_datetime)
  end

  def changeset(learning_style, attrs) do
    learning_style
    |> cast(attrs, [:name, :slug, :description, :tips])
    |> validate_required([:name, :slug, :description, :tips])
    |> validate_length(:name, min: 3, max: 50)
    |> validate_length(:description, min: 10, max: 500)
    |> validate_length(:tips, min: 2, max: 3)
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
  end
end
```

## Query Patterns

### Fetch All Quiz Content (Single Query)

```elixir
def get_quiz_content do
  questions =
    Question
    |> order_by([q], q.position)
    |> preload([q], answer_options: :learning_style)
    |> Repo.all()

  learning_styles = Repo.all(LearningStyle)

  %{questions: questions, learning_styles: learning_styles}
end
```

**Performance**: 2 queries total, minimal joins, fast (<20ms)

### Calculate Result from Answers

```elixir
def calculate_result(answer_ids) do
  # Count learning style frequency
  style_counts =
    AnswerOption
    |> where([a], a.id in ^answer_ids)
    |> group_by([a], a.learning_style_id)
    |> select([a], {a.learning_style_id, count(a.id)})
    |> Repo.all()
    |> Enum.into(%{})

  # Find max count
  {winning_style_id, _count} = Enum.max_by(style_counts, fn {_id, count} -> count end)

  # Handle ties with priority: Visual > Verbal > Structured > Memorizer
  # (Implementation details)

  Repo.get!(LearningStyle, winning_style_id)
end
```

### Record Submission (Optional)

```elixir
def create_submission(attrs) do
  %Submission{}
  |> Submission.changeset(attrs)
  |> Repo.insert()
end
```

## Data Integrity Rules

1. **Referential Integrity**: All foreign keys enforced at database level
2. **No Orphans**: CASCADE deletes for dependent data (answers when question deleted)
3. **Immutable Content**: Learning styles, questions, answers rarely change (migrations for updates)
4. **Append-Only Submissions**: No updates/deletes on submissions (analytics data)
5. **UUID Primary Keys**: Better for distributed systems, shareable links

## Storage Estimates

**Static Content** (one-time):
- 4 learning styles × ~200 bytes = 800 bytes
- 6 questions × ~100 bytes = 600 bytes
- 24 answers × ~150 bytes = 3.6 KB
- **Total static**: ~5 KB

**Submissions** (if tracking):
- Per submission: ~500 bytes (UUID + JSONB + timestamp)
- 1000 submissions/day × 500 bytes = 500 KB/day
- Monthly: ~15 MB
- Yearly: ~180 MB

**Neon Free Tier**: 512 MB storage → 2+ years of submissions at 1k/day

## Backup & Recovery

**Strategy**:
- Neon automatic backups (daily, retained 7 days on free tier)
- Export seed data to version control (quiz content)
- Submission data: Periodic exports to CSV/JSON for archival

**Recovery**:
- Restore from Neon backup for accidental deletions
- Re-run seeds for quiz content
- Historical submissions: restore from CSV exports
