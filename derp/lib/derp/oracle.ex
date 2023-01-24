defmodule Derp.Oracle do
  @moduledoc """
  The Oracle context.
  """

  import Ecto.Query, warn: false
  alias Derp.Repo

  alias Derp.Oracle.ReviewRequest

  import Bitwise
  require Logger

  @doc """
  Returns the list of review_requests.

  ## Examples

      iex> list_review_requests()
      [%ReviewRequest{}, ...]

  """
  def list_review_requests do
    Repo.all(ReviewRequest)
  end

  @doc """
  Gets a single review_request.

  Raises `Ecto.NoResultsError` if the Review request does not exist.

  ## Examples

      iex> get_review_request!(123)
      %ReviewRequest{}

      iex> get_review_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_review_request!(id), do: Repo.get!(ReviewRequest, id)

  def should_we_pay_request?(table, address) do
    now = DateTime.utc_now()
    day_start = %DateTime{now | hour: 0, minute: 0, second: 0}
    day_end = %DateTime{now | hour: 23, minute: 59, second: 59}

    query =
      from r in table,
        select: r.address,
        where:
          r.address == ^address and
            r.updated_at >= ^day_start and
            r.updated_at <= ^day_end

    Repo.exists?(query)
  end

  @doc """
  Creates a review_request.

  ## Examples

      iex> create_review_request(%{field: value})
      {:ok, %ReviewRequest{}}

      iex> create_review_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_review_request(attrs \\ %{}) do
    changeset =
      %ReviewRequest{}
      |> ReviewRequest.create_changeset(attrs)

    IO.inspect(changeset)

    if should_we_pay_request?(ReviewRequest, changeset.changes.address) do
      {:error, :review_token_already_requested}
    else
      Repo.insert_or_update(changeset)
    end
  end

  @doc """
  Updates a review_request.

  ## Examples

      iex> update_review_request(review_request, %{field: new_value})
      {:ok, %ReviewRequest{}}

      iex> update_review_request(review_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_review_request(%ReviewRequest{} = review_request, attrs) do
    review_request
    |> ReviewRequest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a review_request.

  ## Examples

      iex> delete_review_request(review_request)
      {:ok, %ReviewRequest{}}

      iex> delete_review_request(review_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_review_request(%ReviewRequest{} = review_request) do
    Repo.delete(review_request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking review_request changes.

  ## Examples

      iex> change_review_request(review_request)
      %Ecto.Changeset{data: %ReviewRequest{}}

  """
  def change_review_request(%ReviewRequest{} = review_request, attrs \\ %{}) do
    ReviewRequest.changeset(review_request, attrs)
  end


  @stores [%{url: "http://localhost:8080"}]

  # Request all tokens for all products
  def refresh_reviews_for_user(_address, []) do

  end

  # Request just one
  def refresh_reviews_for_user(address, products) do
    Enum.map(products, fn p -> 
      store_id = p &&& (0xFFFFFFFF <<< 32)
      product_id = p &&& 0xFFFFFFFF

      _bought_items = request_external_store(address, Enum.at(@stores, store_id), product_id)
    end)
  end

  defp request_external_store(address, store, product) do
    Logger.info("#{store}/#{product} - #{address}")

    []
  end
end
