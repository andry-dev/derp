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

    if should_we_pay_request?(ReviewRequest, address) do
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
      [] ->
        {:error, :no_new_products}

      products when is_list(products) ->
        IO.inspect(products)
        Derp.Oracle.reward_review_tokens(address, products)

      _error ->
        {:error, :no_new_products}
    end
  end

  # Request just one
  def refresh_reviews_for_user(address, products) when is_list(products) do
    res =
      Enum.map(products, fn p ->
        refresh_reviews_for_user(address, p)
      end)
      |> Enum.all?(fn
        {:ok, res} -> res
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
        0 <<< 32 ||| p
      end)

    {:ok, int_address} = ExW3.Utils.hex_to_integer(address)

    {:ok, claimedProducts} =
      ExW3.Contract.call(:Derp, :getClaimedProductsFromAccount, [int_address])

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
end
