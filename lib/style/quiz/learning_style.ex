defmodule Style.Quiz.LearningStyle do
  @moduledoc """
  Schema for learning style types (Visual Learner, Verbal Processor, etc.)
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "learning_styles" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :tips, {:array, :string}

    has_many :answer_options, Style.Quiz.AnswerOption

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(learning_style, attrs) do
    learning_style
    |> cast(attrs, [:name, :slug, :description, :tips])
    |> validate_required([:name, :slug, :description, :tips])
    |> validate_length(:name, min: 3, max: 50)
    |> validate_length(:slug, min: 3, max: 50)
    |> validate_length(:description, min: 10, max: 500)
    |> validate_length(:tips, min: 2, max: 3)
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
  end
end
