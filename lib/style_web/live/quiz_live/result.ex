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

          # Map learning style slug to image filename
          image_url = get_style_image(learning_style.slug)

          {:ok,
           socket
           |> assign(page_title: "Your Learning Style")
           |> assign(learning_style: learning_style)
           |> assign(image_url: image_url)
           |> assign(session_id: session_id)}
        else
          {:ok,
           socket
           |> put_flash(:info, "Please complete the quiz first")
           |> push_navigate(to: ~p"/quiz/#{session_id}")}
        end
    end
  end

  defp get_style_image(slug) do
    base_url = "https://doy9nvc9lu50w.cloudfront.net/"

    case slug do
      "visual-learner" -> base_url <> "type_visual.png"
      "verbal-processor" -> base_url <> "type_auditory.png"
      "structured-planner" -> base_url <> "type_planner.png"
      "memorizer" -> base_url <> "type_memory.png"
      _ -> base_url <> "coming_soon.png"
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
    <div class="quiz-container">
      <div
        class="result-card"
        phx-hook="QuizCompleted"
        id="result-card"
        data-learning-style={@learning_style.slug}
      >
        <img
          src={@image_url}
          alt={@learning_style.name}
          style="max-width: 100%; height: auto; border-radius: 1rem; margin-bottom: 2rem; background: white; padding: 1rem;"
        />

        <div class="result-header" style="text-align: center;">
          <p style="font-size: 1.5rem; color: #986186; margin-bottom: 1.5rem; font-weight: 400;">
            Your learning style is...
          </p>
          <h1 style="font-size: 4rem; font-weight: bold; margin-bottom: 1.5rem; color: #e68bbe; line-height: 1.2;">
            {@learning_style.name}
          </h1>
          <p class="result-description" style="font-size: 1.25rem;">
            {@learning_style.description}
          </p>
        </div>

        <div class="result-tips">
          <h3>💡 How Exam Mastery supports you:</h3>
          <ul>
            <%= for tip <- @learning_style.tips do %>
              <li>{tip}</li>
            <% end %>
          </ul>
        </div>

        <div class="result-actions">
          <button phx-click="retake_quiz" class="btn btn-secondary">
            Retake Quiz
          </button>
        </div>
      </div>
    </div>
    """
  end
end
