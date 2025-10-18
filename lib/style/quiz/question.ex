defmodule Style.Quiz.Question do
  @moduledoc """
  Schema for quiz questions
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "questions" do
    field :position, :integer
    field :text, :string

    has_many :answer_options, Style.Quiz.AnswerOption

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:position, :text])
    |> validate_required([:position, :text])
    |> validate_number(:position, greater_than_or_equal_to: 1, less_than_or_equal_to: 6)
    |> validate_length(:text, min: 10, max: 500)
    |> unique_constraint(:position)
  end
end
