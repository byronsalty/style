defmodule Style.Quiz.QuizResponse do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "quiz_responses" do
    belongs_to :lead, Style.Quiz.Lead
    belongs_to :question, Style.Quiz.Question
    belongs_to :answer_option, Style.Quiz.AnswerOption

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(quiz_response, attrs) do
    quiz_response
    |> cast(attrs, [:lead_id, :question_id, :answer_option_id])
    |> validate_required([:lead_id, :question_id, :answer_option_id])
    |> unique_constraint([:lead_id, :question_id])
  end
end
