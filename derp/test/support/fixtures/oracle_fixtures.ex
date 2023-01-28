defmodule Derp.OracleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Derp.Oracle` context.
  """

  @doc """
  Generate a review_request.
  """
  def review_request_fixture(attrs \\ %{}) do
    {:ok, review_request} =
      attrs
      |> Enum.into(%{
        address: 42,
        last_request: ~U[2023-01-22 15:03:00Z]
      })
      |> Derp.Oracle.create_review_request()

    review_request
  end

  @doc """
  Generate a product_refresh_request.
  """
  def product_refresh_request_fixture(attrs \\ %{}) do
    {:ok, product_refresh_request} =
      attrs
      |> Enum.into(%{
        address: "some address"
      })
      |> Derp.Oracle.create_product_refresh_request()

    product_refresh_request
  end
end
