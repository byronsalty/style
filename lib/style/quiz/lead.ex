defmodule Style.Quiz.Lead do
  @moduledoc """
  Schema for captured email leads from the quiz
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "leads" do
    field :email, :string
    field :learning_style_slug, :string
    field :metadata, :map, default: %{}
    field :opt_in_courses, :boolean, default: false
    field :opt_in_all_communications, :boolean, default: false

    has_many :quiz_responses, Style.Quiz.QuizResponse

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lead, attrs) do
    lead
    |> cast(attrs, [
      :email,
      :learning_style_slug,
      :metadata,
      :opt_in_courses,
      :opt_in_all_communications
    ])
    |> validate_required([:email, :learning_style_slug])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_length(:email, max: 255)
  end
end
