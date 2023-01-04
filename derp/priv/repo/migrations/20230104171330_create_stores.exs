defmodule Derp.Repo.Migrations.CreateStores do
  use Ecto.Migration

  def change do
    create table(:stores) do
      add :name, :string

      timestamps()
    end
  end
end
