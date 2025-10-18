defmodule StyleWeb.QuizLive.Result do
  use StyleWeb, :live_view

  alias Style.Quiz
  alias Style.Quiz.Session
  alias Style.Repo

  @impl true
  def mount(%{"session_id" => session_id}, _session, socket) do
    case Repo.get(Session, session_id) |> Repo.preload(:lead) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Quiz session not found")
         |> push_navigate(to: ~p"/")}

      quiz_session ->
        if quiz_session.completed_at do
          # Calculate result from session answers
          answer_ids = Map.values(quiz_session.answers)
          learning_style = Quiz.calculate_result(answer_ids)

          {:ok,
           socket
           |> assign(page_title: "Your Learning Style")
           |> assign(learning_style: learning_style)
           |> assign(session_id: session_id)}
        else
          {:ok,
           socket
           |> put_flash(:info, "Please complete the quiz first")
           |> push_navigate(to: ~p"/quiz/#{session_id}")}
        end
    end
  end

  @impl true
  def handle_event("retake_quiz", _params, socket) do
    # Create a new quiz session
    {:ok, new_session} =
      Session.create_session()
      |> Repo.insert()

    {:noreply, push_navigate(socket, to: ~p"/quiz/#{new_session.id}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="quiz-container" style="background: #2d3748; min-height: 100vh; padding: 2rem;">
      <div
        class="result-card"
        phx-hook="QuizCompleted"
        id="result-card"
        data-learning-style={@learning_style.slug}
        style="background: #2d3748; max-width: 1000px; margin: 0 auto; text-align: center; padding: 3rem 2rem;"
      >
        <div class="result-header">
          <p style="font-size: 1.5rem; color: #9ca3af; margin-bottom: 1.5rem; font-weight: 400;">
            Your learning style is...
          </p>
          <h1 style="font-size: 4rem; font-weight: bold; margin-bottom: 1.5rem; color: #1e3a5f; line-height: 1.2;">
            {@learning_style.name}
          </h1>
          <p style="font-size: 1.25rem; color: #e5e7eb; margin-bottom: 3rem; max-width: 800px; margin-left: auto; margin-right: auto;">
            {@learning_style.description}
          </p>
        </div>

        <div style="border-top: 1px solid #4b5563; padding-top: 3rem; margin-bottom: 3rem;">
          <h3 style="font-size: 1.5rem; font-weight: bold; color: #ffffff; margin-bottom: 2rem; text-align: left;">
            Study Tips for You:
          </h3>
          <ul style="list-style: none; padding: 0; text-align: left;">
            <%= for tip <- @learning_style.tips do %>
              <li style="font-size: 1.125rem; color: #e5e7eb; margin-bottom: 1.25rem; padding-left: 1.5rem; position: relative;">
                <span style="position: absolute; left: 0; color: #6366f1;">•</span>
                {tip}
              </li>
            <% end %>
          </ul>
        </div>

        <div style="border-top: 1px solid #4b5563; padding-top: 3rem;">
          <button
            phx-click="retake_quiz"
            style="background: #6366f1; color: white; font-size: 1.125rem; font-weight: 600; padding: 0.875rem 2rem; border-radius: 8px; border: none; cursor: pointer; transition: background 0.2s;"
            onmouseover="this.style.background='#5558e3'"
            onmouseout="this.style.background='#6366f1'"
          >
            Retake Quiz
          </button>
        </div>
      </div>
    </div>
    """
  end
end
