defmodule Derp.Catalogue do
  @moduledoc """
  The Catalogue context.
  """

  import Ecto.Query, warn: false
  alias Derp.Repo

  alias Derp.Catalogue.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  alias Derp.Catalogue.Store

  @doc """
  Returns the list of stores.

  ## Examples

      iex> list_stores()
      [%Store{}, ...]

  """
  def list_stores do
    Repo.all(Store)
  end

  @doc """
  Gets a single store.

  Raises `Ecto.NoResultsError` if the Store does not exist.

  ## Examples

      iex> get_store!(123)
      %Store{}

      iex> get_store!(456)
      ** (Ecto.NoResultsError)

  """
  def get_store!(id), do: Repo.get!(Store, id)

  @doc """
  Creates a store.

  ## Examples

      iex> create_store(%{field: value})
      {:ok, %Store{}}

      iex> create_store(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_store(attrs \\ %{}) do
    %Store{}
    |> Store.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a store.

  ## Examples

      iex> update_store(store, %{field: new_value})
      {:ok, %Store{}}

      iex> update_store(store, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_store(%Store{} = store, attrs) do
    store
    |> Store.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a store.

  ## Examples

      iex> delete_store(store)
      {:ok, %Store{}}

      iex> delete_store(store)
      {:error, %Ecto.Changeset{}}

  """
  def delete_store(%Store{} = store) do
    Repo.delete(store)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking store changes.

  ## Examples

      iex> change_store(store)
      %Ecto.Changeset{data: %Store{}}

  """
  def change_store(%Store{} = store, attrs \\ %{}) do
    Store.changeset(store, attrs)
  end
end
