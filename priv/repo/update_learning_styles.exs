# Script to update learning styles with detailed Exam Mastery benefits
alias Style.Repo
alias Style.Quiz.LearningStyle

# Update Visual Learner
visual = Repo.get_by!(LearningStyle, slug: "visual-learner")
Ecto.Changeset.change(visual, %{
  description: "You learn best when you can see the information. Diagrams, videos, and organized layouts help you retain it.",
  tips: [
    "📘 300+ pages of clean, color-coded study guides across all 7 domains",
    "🧠 Domain One-Pagers inside the Rapid Review Vault simplify complex topics visually",
    "🎥 Strategic video lessons help you see the \"why\" and \"how\" behind each concept",
    "📊 Bonus graph + research decoder sheets help you interpret test visuals with ease"
  ]
})
|> Repo.update!()

IO.puts("Updated Visual Learner")

# Update Verbal Processor
verbal = Repo.get_by!(LearningStyle, slug: "verbal-processor")
Ecto.Changeset.change(verbal, %{
  description: "You understand material best when you talk it through, explain it, or hear it explained aloud.",
  tips: [
    "🎧 Audio Study Loops let you review on the go—perfect for repetition and auditory recall",
    "🗣️ VIP Coaching Option (1:1 calls) gives you a space to talk out strategy and clarify gaps",
    "📝 Teaching-style video walkthroughs simulate instructor-led learning",
    "🗂️ Mock question reviews teach you how to \"think aloud\" through test logic"
  ]
})
|> Repo.update!()

IO.puts("Updated Verbal Processor")

# Update Structured Planner
planner = Repo.get_by!(LearningStyle, slug: "structured-planner")
Ecto.Changeset.change(planner, %{
  description: "You thrive with order, checklists, and clear timelines—you need to know what to do, when, and why.",
  tips: [
    "✅ Study Strategy Toolkit includes a 4-week customizable planner + zone assessment",
    "📚 The full program is organized by domain, with no-fluff lesson flow",
    "📅 You'll know what to study each week and how to track your progress",
    "🧩 Every piece fits into a clear system—from content to review to practice"
  ]
})
|> Repo.update!()

IO.puts("Updated Structured Planner")

# Update Memorizer
memorizer = Repo.get_by!(LearningStyle, slug: "memorizer")
Ecto.Changeset.change(memorizer, %{
  description: "You retain best through repetition, flashcards, and reviewing key info until it sticks.",
  tips: [
    "🃏 Flashcard Deck PDF (Rapid Review Vault) gives you high-yield prompts to drill with",
    "🧠 Mini Mock Exams help reinforce what you've learned under test pressure",
    "🔁 Video & audio content allow for rewatching and relistening—boosting retention",
    "🎯 Focus Ritual Audio helps anchor calm and clarity so you retain more under stress"
  ]
})
|> Repo.update!()

IO.puts("Updated Memorizer")

IO.puts("\n✅ All learning styles updated successfully!")
