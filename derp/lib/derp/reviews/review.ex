defmodule Derp.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    field :body, :string
    field :ipfs_hash, :string
    field :title, :string
    field :user_id, :id
    field :product_id, :id

    timestamps()
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:title, :body, :id, :ipfs_hash])
    |> validate_required([:title, :body, :id, :ipfs_hash])
  end
end
