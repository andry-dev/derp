defmodule Derp.Catalogue.Store do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stores" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(store, attrs) do
    store
    |> cast(attrs, [:name, :id])
    |> validate_required([:name, :id])
  end
end
