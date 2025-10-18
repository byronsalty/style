# Idempotent seed script for quiz content
# Safe to run multiple times - will skip existing records

alias Style.Repo
alias Style.Quiz.{LearningStyle, Question, AnswerOption}

# Seed Learning Styles
IO.puts("Seeding learning styles...")

learning_styles_data = [
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

Enum.each(learning_styles_data, fn attrs ->
  case Repo.get_by(LearningStyle, slug: attrs.slug) do
    nil ->
      %LearningStyle{}
      |> LearningStyle.changeset(attrs)
      |> Repo.insert!()
      IO.puts("  ✓ Created learning style: #{attrs.name}")
    _ ->
      IO.puts("  - Learning style already exists: #{attrs.name}")
  end
end)

# Get learning styles for reference
visual = Repo.get_by!(LearningStyle, slug: "visual-learner")
verbal = Repo.get_by!(LearningStyle, slug: "verbal-processor")
structured = Repo.get_by!(LearningStyle, slug: "structured-planner")
memorizer = Repo.get_by!(LearningStyle, slug: "memorizer")

# Seed Questions
IO.puts("\nSeeding questions...")

questions_data = [
  %{position: 1, text: "When you sit down to study, what helps you focus most?"},
  %{position: 2, text: "What frustrates you most when studying?"},
  %{position: 3, text: "When you need to learn something new, you prefer to:"},
  %{position: 4, text: "If you had 1 hour to review, you'd:"},
  %{position: 5, text: "How do you retain information best?"},
  %{position: 6, text: "You're most motivated when:"}
]

Enum.each(questions_data, fn attrs ->
  case Repo.get_by(Question, position: attrs.position) do
    nil ->
      %Question{}
      |> Question.changeset(attrs)
      |> Repo.insert!()
      IO.puts("  ✓ Created question #{attrs.position}")
    _ ->
      IO.puts("  - Question #{attrs.position} already exists")
  end
end)

# Get questions for reference
q1 = Repo.get_by!(Question, position: 1)
q2 = Repo.get_by!(Question, position: 2)
q3 = Repo.get_by!(Question, position: 3)
q4 = Repo.get_by!(Question, position: 4)
q5 = Repo.get_by!(Question, position: 5)
q6 = Repo.get_by!(Question, position: 6)

# Seed Answer Options
IO.puts("\nSeeding answer options...")

answers_data = [
  # Question 1: When you sit down to study, what helps you focus most?
  %{question_id: q1.id, learning_style_id: visual.id, label: "A", text: "Watching videos or seeing visual examples"},
  %{question_id: q1.id, learning_style_id: verbal.id, label: "B", text: "Talking it through with someone"},
  %{question_id: q1.id, learning_style_id: structured.id, label: "C", text: "Having a clear plan and schedule"},
  %{question_id: q1.id, learning_style_id: memorizer.id, label: "D", text: "Highlighting and re-reading notes"},

  # Question 2: What frustrates you most when studying?
  %{question_id: q2.id, learning_style_id: visual.id, label: "A", text: "Too much text, not enough visuals"},
  %{question_id: q2.id, learning_style_id: verbal.id, label: "B", text: "No one to discuss concepts with"},
  %{question_id: q2.id, learning_style_id: structured.id, label: "C", text: "Unclear instructions or no roadmap"},
  %{question_id: q2.id, learning_style_id: memorizer.id, label: "D", text: "Forgetting things I just studied"},

  # Question 3: When you need to learn something new, you prefer to:
  %{question_id: q3.id, learning_style_id: visual.id, label: "A", text: "Watch it in action or see examples"},
  %{question_id: q3.id, learning_style_id: verbal.id, label: "B", text: "Discuss it and ask questions"},
  %{question_id: q3.id, learning_style_id: structured.id, label: "C", text: "Follow a step-by-step guide"},
  %{question_id: q3.id, learning_style_id: memorizer.id, label: "D", text: "Read, underline, and repeat"},

  # Question 4: If you had 1 hour to review, you'd:
  %{question_id: q4.id, learning_style_id: visual.id, label: "A", text: "Watch or re-watch a video"},
  %{question_id: q4.id, learning_style_id: verbal.id, label: "B", text: "Teach someone else what you know"},
  %{question_id: q4.id, learning_style_id: structured.id, label: "C", text: "Work through an organized outline"},
  %{question_id: q4.id, learning_style_id: memorizer.id, label: "D", text: "Do practice problems or flashcards"},

  # Question 5: How do you retain information best?
  %{question_id: q5.id, learning_style_id: visual.id, label: "A", text: "By visualizing it or seeing diagrams"},
  %{question_id: q5.id, learning_style_id: verbal.id, label: "B", text: "By saying it aloud or explaining it"},
  %{question_id: q5.id, learning_style_id: structured.id, label: "C", text: "By organizing it into frameworks"},
  %{question_id: q5.id, learning_style_id: memorizer.id, label: "D", text: "By repetition and drilling"},

  # Question 6: You're most motivated when:
  %{question_id: q6.id, learning_style_id: visual.id, label: "A", text: "Content is engaging and visual"},
  %{question_id: q6.id, learning_style_id: verbal.id, label: "B", text: "You can discuss progress with others"},
  %{question_id: q6.id, learning_style_id: structured.id, label: "C", text: "You have a clear plan to follow"},
  %{question_id: q6.id, learning_style_id: memorizer.id, label: "D", text: "You see measurable progress"}
]

Enum.each(answers_data, fn attrs ->
  case Repo.get_by(AnswerOption, question_id: attrs.question_id, label: attrs.label) do
    nil ->
      %AnswerOption{}
      |> AnswerOption.changeset(attrs)
      |> Repo.insert!()
      IO.puts("  ✓ Created answer Q#{Repo.get!(Question, attrs.question_id).position}#{attrs.label}")
    _ ->
      q_pos = Repo.get!(Question, attrs.question_id).position
      IO.puts("  - Answer Q#{q_pos}#{attrs.label} already exists")
  end
end)

IO.puts("\n✅ Quiz content seeding complete!")
IO.puts("   - 4 learning styles")
IO.puts("   - 6 questions")
IO.puts("   - 24 answer options")
