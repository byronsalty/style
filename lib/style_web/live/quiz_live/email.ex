defmodule StyleWeb.QuizLive.Email do
  use StyleWeb, :live_view

  alias Style.Quiz
  alias Style.Quiz.Lead
  alias Style.Repo

  on_mount {StyleWeb.QuizSession, :default}

  @impl true
  def mount(_params, _session, socket) do
    try do
      # Get answers from ETS
      answers =
        case :ets.lookup(:quiz_answers, socket.id) do
          [{_id, saved_answers}] -> saved_answers
          [] -> %{}
        end

      if map_size(answers) < 6 do
        # Not all questions answered, redirect back
        {:ok,
         socket
         |> put_flash(:info, "Please answer all questions first")
         |> push_navigate(to: ~p"/")}
      else
        # Calculate result
        answer_ids = Map.values(answers)
        learning_style = Quiz.calculate_result(answer_ids)

        {:ok,
         socket
         |> assign(page_title: "Get Your Results")
         |> assign(learning_style: learning_style)
         |> assign(form: to_form(%{"email" => ""}, as: :email))
         |> assign(error: nil)}
      end
    rescue
      e ->
        require Logger
        Logger.error("Failed to load email capture: #{inspect(e)}")

        {:ok,
         socket
         |> put_flash(:error, "Something went wrong. Please try again.")
         |> push_navigate(to: ~p"/")}
    end
  end

  @impl true
  def handle_event("submit_email", %{"email" => %{"email" => email}}, socket) do
    learning_style = socket.assigns.learning_style

    lead_attrs = %{
      email: String.trim(email),
      learning_style_slug: learning_style.slug,
      metadata: %{
        quiz_completed_at: DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    changeset = Lead.changeset(%Lead{}, lead_attrs)

    case Repo.insert(changeset) do
      {:ok, _lead} ->
        # Track conversion in analytics
        {:noreply,
         socket
         |> push_event("lead_captured", %{learning_style: learning_style.slug})
         |> push_navigate(to: ~p"/result")}

      {:error, changeset} ->
        error_message =
          case changeset.errors[:email] do
            {msg, _} -> msg
            _ -> "Please enter a valid email address"
          end

        {:noreply, assign(socket, error: error_message)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="quiz-container">
      <div class="email-card">
        <div class="email-header">
          <h1>You're almost there!</h1>
          <p class="email-subtitle">
            Enter your email to see your personalized learning style results and study tips.
          </p>
        </div>

        <form phx-submit="submit_email" class="email-form">
          <div class="form-group">
            <label for="email-input" class="form-label">Email Address</label>
            <input
              type="email"
              id="email-input"
              name="email[email]"
              placeholder="your@email.com"
              class="form-input"
              required
              autofocus
            />
            <%= if @error do %>
              <p class="form-error"><%= @error %></p>
            <% end %>
          </div>

          <button type="submit" class="btn btn-primary btn-block">
            Show Me My Results →
          </button>

          <p class="privacy-note">
            We'll send you personalized study tips and resources. Unsubscribe anytime.
          </p>
        </form>
      </div>
    </div>
    """
  end
end
