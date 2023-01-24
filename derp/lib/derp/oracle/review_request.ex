defmodule Derp.Oracle.ReviewRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "review_requests" do
    field :address, :string
    field :products, {:array, :integer}, virtual: true

    timestamps()
  end

  @doc false
  def changeset(review_request, attrs) do
    review_request
    |> cast(attrs, [:address])
    |> validate_required([:address])
  end

  @doc false
  def create_changeset(review_request, attrs) do
    review_request
    |> cast(attrs, [:address, :products])
    |> validate_required([:address])
  end
end
