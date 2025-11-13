defmodule StyleWeb.QuizLive.Question do
  use StyleWeb, :live_view

  alias Style.Quiz
  alias Style.Quiz.Lead
  alias Style.Quiz.QuizResponse
  alias Style.Quiz.Session
  alias Style.Repo
  alias Style.Services.ConvertKitSubscriber
  alias Ecto.Multi

  @impl true
  def mount(%{"session_id" => session_id}, _session, socket) do
    # Load the quiz session from database
    case Repo.get(Session, session_id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Quiz session not found")
         |> push_navigate(to: ~p"/")}

      quiz_session ->
        # Load quiz content
        %{questions: questions, learning_styles: _styles} = Quiz.get_quiz_content()

        # Determine current step based on position
        cond do
          quiz_session.current_position >= 1 and quiz_session.current_position <= 6 ->
            # Show question
            question = Enum.find(questions, &(&1.position == quiz_session.current_position))

            {:ok,
             socket
             |> assign(session_id: session_id)
             |> assign(quiz_session: quiz_session)
             |> assign(step: :question)
             |> assign(position: quiz_session.current_position)
             |> assign(question: question)
             |> assign(selected_answer: Map.get(quiz_session.answers, question.id))
             |> assign(page_title: "Question #{quiz_session.current_position} of 6")}

          quiz_session.current_position == 7 ->
            # Show email capture
            answer_ids = Map.values(quiz_session.answers)
            learning_style = Quiz.calculate_result(answer_ids)

            {:ok,
             socket
             |> assign(session_id: session_id)
             |> assign(quiz_session: quiz_session)
             |> assign(step: :email)
             |> assign(position: 7)
             |> assign(learning_style: learning_style)
             |> assign(form: to_form(%{"email" => ""}, as: :email))
             |> assign(error: nil)
             |> assign(page_title: "Get Your Results")}

          true ->
            {:ok,
             socket
             |> put_flash(:error, "Invalid quiz state")
             |> push_navigate(to: ~p"/")}
        end
    end
  end

  @impl true
  def handle_event("select_answer", %{"answer_id" => answer_id}, socket) do
    question_id = socket.assigns.question.id
    quiz_session = socket.assigns.quiz_session

    # Update answers in the session
    new_answers = Map.put(quiz_session.answers, question_id, answer_id)

    {:ok, updated_session} =
      quiz_session
      |> Session.changeset(%{answers: new_answers})
      |> Repo.update()

    {:noreply,
     socket
     |> assign(quiz_session: updated_session)
     |> assign(selected_answer: answer_id)}
  end

  @impl true
  def handle_event("next_question", _params, socket) do
    quiz_session = socket.assigns.quiz_session

    # Advance position
    {:ok, updated_session} =
      quiz_session
      |> Session.changeset(%{current_position: quiz_session.current_position + 1})
      |> Repo.update()

    # Reload the page with new position
    {:noreply, push_navigate(socket, to: ~p"/quiz/#{updated_session.id}")}
  end

  @impl true
  def handle_event("previous_question", _params, socket) do
    quiz_session = socket.assigns.quiz_session

    if quiz_session.current_position > 1 do
      # Go back
      {:ok, updated_session} =
        quiz_session
        |> Session.changeset(%{current_position: quiz_session.current_position - 1})
        |> Repo.update()

      {:noreply, push_navigate(socket, to: ~p"/quiz/#{updated_session.id}")}
    else
      {:noreply, push_navigate(socket, to: ~p"/")}
    end
  end

  @impl true
  def handle_event("submit_email", %{"email" => email_params}, socket) do
    learning_style = socket.assigns.learning_style
    quiz_session = socket.assigns.quiz_session

    lead_attrs = %{
      email: String.trim(email_params["email"]),
      learning_style_slug: learning_style.slug,
      opt_in_courses: email_params["opt_in_courses"] == "true",
      opt_in_all_communications: email_params["opt_in_all_communications"] == "true",
      metadata: %{
        quiz_completed_at: DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }

    # Use Multi to insert lead, quiz responses, and mark session complete
    multi =
      Multi.new()
      |> Multi.insert(:lead, Lead.changeset(%Lead{}, lead_attrs))
      |> Multi.run(:quiz_responses, fn _repo, %{lead: lead} ->
        responses =
          Enum.map(quiz_session.answers, fn {question_id, answer_option_id} ->
            %{
              lead_id: lead.id,
              question_id: question_id,
              answer_option_id: answer_option_id,
              inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
              updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
            }
          end)

        {count, _} = Repo.insert_all(QuizResponse, responses)
        {:ok, count}
      end)
      |> Multi.update(:session, Session.mark_completed(quiz_session, nil))
      |> Multi.run(:update_session_lead, fn _repo, %{lead: lead, session: session} ->
        Session.changeset(session, %{lead_id: lead.id})
        |> Repo.update()
      end)

    case Repo.transaction(multi) do
      {:ok, %{lead: lead}} ->
        # Subscribe to ConvertKit asynchronously (don't block on success/failure)
        Task.start(fn ->
          ConvertKitSubscriber.subscribe_lead(lead)
        end)

        {:noreply, push_navigate(socket, to: ~p"/result/#{quiz_session.id}")}

      {:error, :lead, changeset, _changes} ->
        error_message =
          case changeset.errors[:email] do
            {msg, _} -> msg
            _ -> "Please enter a valid email address"
          end

        {:noreply, assign(socket, error: error_message)}

      {:error, _operation, _reason, _changes} ->
        {:noreply, assign(socket, error: "Something went wrong. Please try again.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="quiz-container">
      <%= if @step == :question do %>
        <div class="quiz-progress">
          <div class="progress-text">Question {@position} of 6</div>
          <div class="progress-bar">
            <div class="progress-fill" style={"width: #{@position / 6 * 100}%"}></div>
          </div>
        </div>

        <div class="question-card">
          <h2 class="question-text">{@question.text}</h2>

          <div class="answer-options">
            <%= for option <- @question.answer_options do %>
              <button
                phx-click="select_answer"
                phx-value-answer_id={option.id}
                class={[
                  "answer-option",
                  @selected_answer == option.id && "selected"
                ]}
              >
                <span class="answer-label">{option.label}</span>
                <span class="answer-text">{option.text}</span>
              </button>
            <% end %>
          </div>

          <div class="navigation-buttons">
            <button
              :if={@position > 1}
              phx-click="previous_question"
              class="btn btn-secondary"
            >
              ← Previous
            </button>

            <button
              phx-click="next_question"
              disabled={is_nil(@selected_answer)}
              class="btn btn-primary"
            >
              {if @position < 6, do: "Next →", else: "Continue →"}
            </button>
          </div>
        </div>
      <% else %>
        <div class="quiz-progress">
          <div class="progress-text">All questions complete!</div>
          <div class="progress-bar">
            <div class="progress-fill" style="width: 100%"></div>
          </div>
        </div>

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
              <%= if assigns[:error] do %>
                <p class="form-error">{@error}</p>
              <% end %>
            </div>

            <div class="form-group" style="margin-top: 1rem;">
              <label class="checkbox-label">
                <input
                  type="checkbox"
                  name="email[opt_in_courses]"
                  value="true"
                  checked
                />
                <span>Add me to future courses by Margaret Salty</span>
              </label>
            </div>

            <div class="form-group">
              <label class="checkbox-label">
                <input
                  type="checkbox"
                  name="email[opt_in_all_communications]"
                  value="true"
                  checked
                />
                <span>Add me to all communications from Margaret Salty</span>
              </label>
            </div>

            <button type="submit" class="btn btn-primary btn-block" style="margin-top: 1.5rem;">
              Show Me My Results →
            </button>

            <p class="privacy-note">
              We'll send you personalized study tips and resources. Unsubscribe anytime.
            </p>
          </form>

          <div class="navigation-buttons" style="margin-top: 1.5rem;">
            <button phx-click="previous_question" class="btn btn-secondary">
              ← Back to Questions
            </button>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
