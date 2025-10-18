defmodule Style.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def up do
    create table(:questions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :position, :integer, null: false
      add :text, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:questions, [:position])
    create constraint(:questions, :valid_position, check: "position >= 1 AND position <= 6")
  end

  def down do
    drop table(:questions)
  end
end
