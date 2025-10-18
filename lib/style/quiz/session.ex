defmodule Style.Quiz.Session do
  @moduledoc """
  Represents a quiz session - tracks progress through the quiz
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "quiz_sessions" do
    field :current_position, :integer, default: 1
    field :answers, :map, default: %{}
    field :completed_at, :utc_datetime

    belongs_to :lead, Style.Quiz.Lead

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:current_position, :answers, :completed_at, :lead_id])
    |> validate_required([:current_position, :answers])
    |> validate_number(:current_position, greater_than_or_equal_to: 1, less_than_or_equal_to: 7)
  end

  @doc """
  Creates a new quiz session
  """
  def create_session do
    %__MODULE__{}
    |> changeset(%{current_position: 1, answers: %{}})
  end

  @doc """
  Updates the session with a new answer
  """
  def update_answer(session, question_id, answer_id) do
    answers = Map.put(session.answers, question_id, answer_id)
    changeset(session, %{answers: answers})
  end

  @doc """
  Advances to the next position
  """
  def advance_position(session) do
    changeset(session, %{current_position: session.current_position + 1})
  end

  @doc """
  Goes back to the previous position
  """
  def previous_position(session) do
    new_position = max(1, session.current_position - 1)
    changeset(session, %{current_position: new_position})
  end

  @doc """
  Marks the session as completed
  """
  def mark_completed(session, lead_id) do
    changeset(session, %{
      completed_at: DateTime.utc_now(),
      lead_id: lead_id
    })
  end
end
