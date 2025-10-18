defmodule Style.Repo.Migrations.CreateLeads do
  use Ecto.Migration

  def change do
    create table(:leads, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :learning_style_slug, :string, null: false
      add :metadata, :jsonb, default: "{}"

      timestamps(type: :utc_datetime)
    end

    create index(:leads, [:email])
    create index(:leads, [:learning_style_slug])
    create index(:leads, [:inserted_at])
  end
end
