defmodule Derp.ReviewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Derp.Reviews` context.
  """

  @doc """
  Generate a review.
  """
  def review_fixture(attrs \\ %{}) do
    {:ok, review} =
      attrs
      |> Enum.into(%{
        body: "some body",
        id: 42,
        ipfs_hash: "some ipfs_hash",
        title: "some title"
      })
      |> Derp.Reviews.create_review()

    review
  end
end
