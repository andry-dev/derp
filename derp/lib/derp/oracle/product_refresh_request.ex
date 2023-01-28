defmodule Derp.Oracle.ProductRefreshRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_refresh_requests" do
    field :address, :string
    field :products, {:array, :integer}, virtual: true

    timestamps()
  end

  @doc false
  def changeset(product_refresh_request, attrs) do
    product_refresh_request
    |> cast(attrs, [:address, :products])
    |> validate_required([:address, :products])
  end
end
