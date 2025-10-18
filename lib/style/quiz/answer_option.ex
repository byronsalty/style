defmodule Style.Quiz.AnswerOption do
  @moduledoc """
  Schema for quiz answer options
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "answer_options" do
    field :label, :string
    field :text, :string

    belongs_to :question, Style.Quiz.Question, type: :binary_id
    belongs_to :learning_style, Style.Quiz.LearningStyle, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(answer_option, attrs) do
    answer_option
    |> cast(attrs, [:question_id, :learning_style_id, :label, :text])
    |> validate_required([:question_id, :learning_style_id, :label, :text])
    |> validate_inclusion(:label, ["A", "B", "C", "D"])
    |> validate_length(:text, min: 5, max: 300)
    |> foreign_key_constraint(:question_id)
    |> foreign_key_constraint(:learning_style_id)
    |> unique_constraint([:question_id, :label])
  end
end
