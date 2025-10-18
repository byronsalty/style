defmodule Style.Repo.Migrations.CreateLearningStyles do
  use Ecto.Migration

  def up do
    create table(:learning_styles, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, size: 50, null: false
      add :slug, :string, size: 50, null: false
      add :description, :text, null: false
      add :tips, :jsonb, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:learning_styles, [:slug])
    create unique_index(:learning_styles, [:name])
  end

  def down do
    drop table(:learning_styles)
  end
end
