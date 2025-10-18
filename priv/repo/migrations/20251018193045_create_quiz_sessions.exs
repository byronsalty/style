defmodule Style.Repo.Migrations.CreateQuizSessions do
  use Ecto.Migration

  def change do
    create table(:quiz_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :current_position, :integer, default: 1, null: false
      add :answers, :jsonb, default: "{}", null: false
      add :completed_at, :utc_datetime
      add :lead_id, references(:leads, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:quiz_sessions, [:lead_id])
    create index(:quiz_sessions, [:inserted_at])
  end
end
