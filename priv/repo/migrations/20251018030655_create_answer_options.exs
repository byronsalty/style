defmodule Style.Repo.Migrations.CreateAnswerOptions do
  use Ecto.Migration

  def up do
    create table(:answer_options, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :question_id, references(:questions, type: :uuid, on_delete: :delete_all), null: false

      add :learning_style_id, references(:learning_styles, type: :uuid, on_delete: :restrict),
        null: false

      add :label, :string, size: 1, null: false
      add :text, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:answer_options, [:question_id])
    create index(:answer_options, [:learning_style_id])
    create unique_index(:answer_options, [:question_id, :label])
    create constraint(:answer_options, :valid_label, check: "label IN ('A', 'B', 'C', 'D')")
  end

  def down do
    drop table(:answer_options)
  end
end
