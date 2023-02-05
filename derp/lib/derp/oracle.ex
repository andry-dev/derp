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

  def should_user_pay_request?(table, address) do
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

    address = changeset.changes.address
    products = changeset.changes.products || []

    if should_user_pay_request?(ReviewRequest, address) do
      {:error, :review_token_already_requested}
    else
      case refresh_reviews_for_user(address, products) do
        {:ok, true} ->
          Repo.insert_or_update(changeset)
          {:ok, true}

        error ->
          error
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

  def decode_product_id(product) do
    store_id = (product &&& 0xFFFFFFFF <<< 32) >>> 32
    product_id = product &&& 0xFFFFFFFF

    {store_id, product_id}
  end

  def encode_product_id(store, product) do
    store <<< 32 ||| product
  end

  # Request all tokens for all products
  def refresh_reviews_for_user(address, []) do
    Logger.info("Refreshing tokens for #{address}...")
    case check_new_bought_products(address) do
      [] -> {:error, :no_new_products}
      products when is_list(products) ->
        IO.inspect(products)
        Derp.Oracle.reward_review_tokens(address, products)
      _error -> {:error, :no_new_products}
    end
  end

  # Request just one
  def refresh_reviews_for_user(address, products) when is_list(products) do
    res = Enum.map(products, fn p ->
      refresh_reviews_for_user(address, p)
    end)
    |> Enum.all?(fn {:ok, res} -> res
      {:error, _reason} -> false
    end)

    if res do
      {:ok, true}
    else
      {:error, "User didn't buy product"}
    end
  end

  def refresh_reviews_for_user(address, product) do
    {store_id, product_id} = decode_product_id(product)

    case user_bought_product?(address, store_id, product_id) do
      {:ok, true} ->
        Derp.Oracle.reward_review_tokens(address, product)

      {:ok, false} ->
        {:ok, false}

      error ->
        error
    end
  end

  defp user_bought_product?(address, 0, product) do
    Logger.info("Trying to check if #{address} bought #{product} for store 0...")

    store_url = "localhost:8080/check/#{product}"
    headers = [{"Content-Type", "application/json"}]

    with {:ok, json} <- Jason.encode(%{address: address}),
         {:ok, response} <- HTTPoison.post(store_url, json, headers),
         {:ok, %{"bought" => result}} <- Jason.decode(response.body) do
      {:ok, result}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp user_bought_product?(_address, store, _product) do
    {:error, "Unknown store #{store}"}
  end

  def check_new_bought_products(address) do
    products =
      get_bought_products_from_store(address, 0)
      |> Enum.map(fn p -> 
        (0 <<< 32) ||| p
      end)

    {:ok, int_address} = ExW3.Utils.hex_to_integer(address)

    {:ok, claimedProducts} = ExW3.Contract.call(:Derp, :getClaimedProductsFromAccount, [int_address])

    products -- claimedProducts
  end

  defp get_bought_products_from_store(address, 0) do
    Logger.info("Trying to check if #{address} bought new products...")

    store_url = "localhost:8080/check"
    headers = [{"Content-Type", "application/json"}]

    with {:ok, json} <- Jason.encode(%{address: address}),
         {:ok, response} <- HTTPoison.post(store_url, json, headers),
         {:ok, %{"data" => result}} <- Jason.decode(response.body) do
      result
    else
      error -> error
    end 
  end

  defp get_bought_products_from_store(_address, _store), do: []

  def reward_review_tokens(address, products) when is_list(products) do
    Enum.each(products, fn p ->
      reward_review_tokens(address, p)
    end)

    {:ok, true}

    # TODO: Truffle doesn't like the fact that we iterate over an array inside the contract, so we take the pessimization and do N transactions for each product. This is not ideal because we pay too much and we should use the code below.

    # options = %{
    #   from: Enum.at(ExW3.accounts(), 0),
    #   gas: 1_000_000
    # }
    #
    # Logger.info("Trying to reward user for products #{inspect(products)}")
    #
    # {:ok, int_address} = ExW3.Utils.hex_to_integer(address)
    #
    # case ExW3.Contract.send(:Derp, :rewardReviewTokens, [int_address, products, length(products)], options) do
    #   {:ok, res} ->
    #     Logger.info(
    #       "Rewarded user #{address} for products #{inspect(products)}. Got #{res} from contract."
    #     )
    #
    #     {:ok, true}
    # end
  end

  def reward_review_tokens(address, product) do
    options = %{
      # from: Application.fetch_env!(:derp, :server_address, Enum.at(ExW3.accounts, 0)),

      from: Enum.at(ExW3.accounts(), 0),
      gas: 1_000_000
    }

    {:ok, int_address} = ExW3.Utils.hex_to_integer(address)

    {store_id, local_product_id} = Derp.Oracle.decode_product_id(product)

    case ExW3.Contract.send(:Derp, :rewardReviewToken, [int_address, product], options) do
      {:ok, result} ->
        Logger.info(
          "Rewarded user #{address} for product #{product} (#{store_id}, #{local_product_id})"
        )

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

    if should_user_pay_request?(ProductRefreshRequest, changeset.changes.address) do
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
  def change_product_refresh_request(
        %ProductRefreshRequest{} = product_refresh_request,
        attrs \\ %{}
      ) do
    ProductRefreshRequest.changeset(product_refresh_request, attrs)
  end
end
