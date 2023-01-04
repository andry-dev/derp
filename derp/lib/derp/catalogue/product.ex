defmodule Derp.Catalogue.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :local_id, :integer
    field :name, :string
    field :store_id, :id

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :id, :local_id])
    |> validate_required([:name, :id, :local_id])
  end
end
