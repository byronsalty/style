defmodule Style.Quiz do
  @moduledoc """
  The Quiz context.
  Handles quiz content retrieval and result calculation.
  """

  import Ecto.Query, warn: false
  alias Style.Repo

  alias Style.Quiz.{LearningStyle, Question, AnswerOption}

  @doc """
  Returns all quiz content needed for the frontend:
  - All 6 questions in order with their answer options
  - All 4 learning styles with tips

  ## Examples

      iex> get_quiz_content()
      %{questions: [...], learning_styles: [...]}

  """
  def get_quiz_content do
    # Load questions and manually sort answer options by label
    questions =
      Question
      |> order_by([q], q.position)
      |> preload([q], answer_options: :learning_style)
      |> Repo.all()
      |> Enum.map(fn question ->
        # Sort answer options by label (A, B, C, D)
        sorted_options = Enum.sort_by(question.answer_options, & &1.label)
        %{question | answer_options: sorted_options}
      end)

    learning_styles = Repo.all(LearningStyle)

    %{questions: questions, learning_styles: learning_styles}
  end

  @doc """
  Calculates the learning style result from a list of answer IDs.
  Implements tie-breaking logic: Visual > Verbal > Structured > Memorizer

  ## Examples

      iex> calculate_result([answer1_id, answer2_id, ...])
      %LearningStyle{name: "Visual Learner", ...}

  """
  def calculate_result(answer_ids) when is_list(answer_ids) and length(answer_ids) == 6 do
    # Get all answer options with their learning styles
    answer_options =
      AnswerOption
      |> where([a], a.id in ^answer_ids)
      |> preload(:learning_style)
      |> Repo.all()

    # Count frequency of each learning style
    style_counts =
      answer_options
      |> Enum.group_by(& &1.learning_style.slug)
      |> Enum.map(fn {slug, answers} -> {slug, length(answers)} end)
      |> Enum.into(%{})

    # Find max count
    max_count = style_counts |> Map.values() |> Enum.max()

    # Get all styles with max count
    tied_styles =
      style_counts
      |> Enum.filter(fn {_, count} -> count == max_count end)
      |> Enum.map(fn {slug, _} -> slug end)

    # Apply tie-breaking priority: visual-learner > verbal-processor > structured-planner > memorizer
    priority_order = ["visual-learner", "verbal-processor", "structured-planner", "memorizer"]

    winning_slug =
      priority_order
      |> Enum.find(fn slug -> slug in tied_styles end)

    # Fetch and return the learning style
    Repo.get_by!(LearningStyle, slug: winning_slug)
  end

  @doc """
  Validates that exactly 6 valid answer IDs are provided.
  """
  def validate_answers(answer_ids) when is_list(answer_ids) do
    with true <- length(answer_ids) == 6,
         valid_ids <- get_valid_answer_ids(),
         true <- Enum.all?(answer_ids, fn id -> id in valid_ids end) do
      {:ok, answer_ids}
    else
      false -> {:error, "Must provide exactly 6 valid answer IDs"}
      _ -> {:error, "Invalid answer IDs provided"}
    end
  end

  def validate_answers(_), do: {:error, "Answer IDs must be a list"}

  defp get_valid_answer_ids do
    AnswerOption
    |> select([a], a.id)
    |> Repo.all()
  end
end
