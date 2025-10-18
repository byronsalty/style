defmodule Style.Repo.Migrations.AddConsentFieldsToLeads do
  use Ecto.Migration

  def change do
    alter table(:leads) do
      add :opt_in_courses, :boolean, default: false, null: false
      add :opt_in_all_communications, :boolean, default: false, null: false
    end

    create index(:leads, [:opt_in_courses])
    create index(:leads, [:opt_in_all_communications])
  end
end
