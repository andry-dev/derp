defmodule Derp.Repo.Migrations.CreateProductRefreshRequests do
  use Ecto.Migration

  def change do
    create table(:product_refresh_requests) do
      add :address, :string

      timestamps()
    end
  end
end
