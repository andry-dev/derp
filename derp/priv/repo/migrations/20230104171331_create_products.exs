defmodule Derp.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :local_id, :integer
      add :store_id, references(:stores, on_delete: :nothing)

      timestamps()
    end

    create index(:products, [:store_id])
  end
end
