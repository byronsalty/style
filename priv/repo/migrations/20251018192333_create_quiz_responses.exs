defmodule Style.Repo.Migrations.CreateQuizResponses do
  use Ecto.Migration

  def change do
    create table(:quiz_responses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :lead_id, references(:leads, type: :binary_id, on_delete: :delete_all), null: false

      add :question_id, references(:questions, type: :binary_id, on_delete: :restrict),
        null: false

      add :answer_option_id, references(:answer_options, type: :binary_id, on_delete: :restrict),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:quiz_responses, [:lead_id])
    create index(:quiz_responses, [:question_id])
    create index(:quiz_responses, [:answer_option_id])
    create unique_index(:quiz_responses, [:lead_id, :question_id])
  end
end
