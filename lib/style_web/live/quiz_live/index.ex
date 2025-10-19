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
      <img
        src="https://doy9nvc9lu50w.cloudfront.net/ms_logo_rect.png"
        alt="MS Logo"
        style="max-width: 200px; height: auto; margin: 0 auto; display: block;"
      />

      <div class="quiz-intro">
        <img
          src="https://doy9nvc9lu50w.cloudfront.net/begin.png"
          alt="What's Your Study Style?"
          style="max-width: 100%; height: auto; border-radius: 1rem; margin-bottom: 2rem; background: white; padding: 1rem;"
        />

        <h1>What's Your Study Style?</h1>
        <p class="subtitle">Discover your learning style in under 2 minutes</p>

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
