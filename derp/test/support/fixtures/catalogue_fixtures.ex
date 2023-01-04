defmodule Derp.CatalogueFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Derp.Catalogue` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        id: 42,
        local_id: 42,
        name: "some name"
      })
      |> Derp.Catalogue.create_product()

    product
  end

  @doc """
  Generate a store.
  """
  def store_fixture(attrs \\ %{}) do
    {:ok, store} =
      attrs
      |> Enum.into(%{
        id: 42,
        name: "some name"
      })
      |> Derp.Catalogue.create_store()

    store
  end
end
