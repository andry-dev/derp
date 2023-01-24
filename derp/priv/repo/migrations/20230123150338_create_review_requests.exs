defmodule Derp.Repo.Migrations.CreateReviewRequests do
  use Ecto.Migration

  def change do
    create table(:review_requests) do
      add :address, :string

      timestamps()
    end

    create unique_index(:review_requests, [:address])
  end
end
