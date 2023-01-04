defmodule DerpWeb.StoreController do
  use DerpWeb, :controller

  alias Derp.Catalogue
  alias Derp.Catalogue.Store

  def index(conn, _params) do
    stores = Catalogue.list_stores()
    render(conn, "index.html", stores: stores)
  end

  def new(conn, _params) do
    changeset = Catalogue.change_store(%Store{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"store" => store_params}) do
    case Catalogue.create_store(store_params) do
      {:ok, store} ->
        conn
        |> put_flash(:info, "Store created successfully.")
        |> redirect(to: Routes.store_path(conn, :show, store))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    store = Catalogue.get_store!(id)
    render(conn, "show.html", store: store)
  end

  def edit(conn, %{"id" => id}) do
    store = Catalogue.get_store!(id)
    changeset = Catalogue.change_store(store)
    render(conn, "edit.html", store: store, changeset: changeset)
  end

  def update(conn, %{"id" => id, "store" => store_params}) do
    store = Catalogue.get_store!(id)

    case Catalogue.update_store(store, store_params) do
      {:ok, store} ->
        conn
        |> put_flash(:info, "Store updated successfully.")
        |> redirect(to: Routes.store_path(conn, :show, store))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", store: store, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    store = Catalogue.get_store!(id)
    {:ok, _store} = Catalogue.delete_store(store)

    conn
    |> put_flash(:info, "Store deleted successfully.")
    |> redirect(to: Routes.store_path(conn, :index))
  end
end
