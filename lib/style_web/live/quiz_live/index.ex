defmodule StyleWeb.QuizLive.Index do
  use StyleWeb, :live_view

  alias Style.Quiz.Session
  alias Style.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "What's Your Study Style?")}
  end

  @impl true
  def handle_event("start_quiz", _params, socket) do
    # Create a new quiz session in the database
    {:ok, quiz_session} =
      Session.create_session()
      |> Repo.insert()

    # Redirect to the quiz with the session ID
    {:noreply, push_navigate(socket, to: ~p"/quiz/#{quiz_session.id}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="quiz-container">
      <div class="quiz-intro">
        <h1>What's Your Study Style?</h1>
        <p class="subtitle">Discover your learning style in under 2 minutes</p>

        <div class="intro-content">
          <p>Take this quick quiz to find out if you're a:</p>
          <ul>
            <li><strong>Visual Learner</strong> - Loves diagrams and color-coded notes</li>
            <li><strong>Verbal Processor</strong> - Learns by speaking and teaching</li>
            <li><strong>Structured Planner</strong> - Needs clarity and order</li>
            <li><strong>Memorizer</strong> - Repetition and flashcards work best</li>
          </ul>
        </div>

        <button
          phx-click="start_quiz"
          class="btn btn-primary btn-large"
          phx-hook="QuizStarted"
          id="start-quiz-btn"
        >
          Start Quiz
        </button>
      </div>
    </div>
    """
  end
end
