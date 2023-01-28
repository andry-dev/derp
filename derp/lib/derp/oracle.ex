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

    address = changeset.changes.address
    products = changeset.changes.products || []

    if should_we_pay_request?(ReviewRequest, address) do
      {:error, :review_token_already_requested}
    else
      case refresh_reviews_for_user(address, products) do
        {:ok, true} ->
          Repo.insert_or_update(changeset)
          {:ok, true}
        error -> error
      end

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


  def decode_product_id(product) do
    store_id = (product &&& (0xFFFFFFFF <<< 32)) >>> 32
    product_id = product &&& 0xFFFFFFFF

    {store_id, product_id}
  end

  def encode_product_id(store, product) do
    (store <<< 32) ||| product
  end

  # Request all tokens for all products
  def refresh_reviews_for_user(_address, []), do: false

  # Request just one
  def refresh_reviews_for_user(address, products) when is_list(products) do
    Enum.each(products, fn p ->
      {store_id, product_id} = decode_product_id(p)

      user_bought_product?(address, Enum.at(@stores, store_id), product_id)
    end)
  end

  def refresh_reviews_for_user(address, product) do
      {store_id, product_id} = decode_product_id(product)

    case user_bought_product?(address, store_id, product_id) do
        {:ok, true} ->
            Derp.Oracle.reward_review_tokens(address, product)
        {:ok, false} ->
          {:ok, false}
        error -> error
    end
  end

  defp user_bought_product?(address, 1, product) do
    Logger.info("Trying to check if #{address} bought #{product} for store 1...")

    store_url = "localhost:8080/check/#{product}"
    headers = [{"Content-Type", "application/json"}]

    with {:ok, json} <- Jason.encode(%{address: address}),
         {:ok, response}  <- HTTPoison.post(store_url, json, headers),
         {:ok, %{"bought" => result}} <- Jason.decode(response.body) do
      {:ok, result}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp user_bought_product?(_address, store, _product) do
    {:error, "Unknown store #{store}"}
  end

  def reward_review_tokens(address, product) do
      options = %{
        #from: Application.fetch_env!(:derp, :server_address, Enum.at(ExW3.accounts, 0)),

        from: Enum.at(ExW3.accounts, 0),
        gas: 100_000
      }

      {:ok, int_address} = ExW3.Utils.hex_to_integer(address)

      {store_id, local_product_id} = Derp.Oracle.decode_product_id(product)

      case ExW3.Contract.send(:Derp, :rewardReviewToken, [int_address, product], options) do
        {:ok, result} ->
          Logger.info("Rewarded user #{address} for product #{product} (#{store_id}, #{local_product_id})")
          {:ok, result}
      end
  end

  alias Derp.Oracle.ProductRefreshRequest

  @doc """
  Returns the list of product_refresh_requests.

  ## Examples

      iex> list_product_refresh_requests()
      [%ProductRefreshRequest{}, ...]

  """
  def list_product_refresh_requests do
    Repo.all(ProductRefreshRequest)
  end

  @doc """
  Gets a single product_refresh_request.

  Raises `Ecto.NoResultsError` if the Product refresh request does not exist.

  ## Examples

      iex> get_product_refresh_request!(123)
      %ProductRefreshRequest{}

      iex> get_product_refresh_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product_refresh_request!(id), do: Repo.get!(ProductRefreshRequest, id)

  @doc """
  Creates a product_refresh_request.

  ## Examples

      iex> create_product_refresh_request(%{field: value})
      {:ok, %ProductRefreshRequest{}}

      iex> create_product_refresh_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product_refresh_request(attrs \\ %{}) do
    changeset =
      %ProductRefreshRequest{}
      |> ProductRefreshRequest.changeset(attrs)

    if should_we_pay_request?(ProductRefreshRequest, changeset.changes.address) do
      {:error, :product_refresh_already_requested}
    else
      Repo.insert_or_update(changeset)
    end
  end

  @doc """
  Updates a product_refresh_request.

  ## Examples

      iex> update_product_refresh_request(product_refresh_request, %{field: new_value})
      {:ok, %ProductRefreshRequest{}}

      iex> update_product_refresh_request(product_refresh_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product_refresh_request(%ProductRefreshRequest{} = product_refresh_request, attrs) do
    product_refresh_request
    |> ProductRefreshRequest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product_refresh_request.

  ## Examples

      iex> delete_product_refresh_request(product_refresh_request)
      {:ok, %ProductRefreshRequest{}}

      iex> delete_product_refresh_request(product_refresh_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product_refresh_request(%ProductRefreshRequest{} = product_refresh_request) do
    Repo.delete(product_refresh_request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product_refresh_request changes.

  ## Examples

      iex> change_product_refresh_request(product_refresh_request)
      %Ecto.Changeset{data: %ProductRefreshRequest{}}

  """
  def change_product_refresh_request(%ProductRefreshRequest{} = product_refresh_request, attrs \\ %{}) do
    ProductRefreshRequest.changeset(product_refresh_request, attrs)
  end
end
