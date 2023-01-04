defmodule Derp.CatalogueTest do
  use Derp.DataCase

  alias Derp.Catalogue

  describe "products" do
    alias Derp.Catalogue.Product

    import Derp.CatalogueFixtures

    @invalid_attrs %{id: nil, local_id: nil, name: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Catalogue.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Catalogue.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{id: 42, local_id: 42, name: "some name"}

      assert {:ok, %Product{} = product} = Catalogue.create_product(valid_attrs)
      assert product.id == 42
      assert product.local_id == 42
      assert product.name == "some name"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalogue.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{id: 43, local_id: 43, name: "some updated name"}

      assert {:ok, %Product{} = product} = Catalogue.update_product(product, update_attrs)
      assert product.id == 43
      assert product.local_id == 43
      assert product.name == "some updated name"
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalogue.update_product(product, @invalid_attrs)
      assert product == Catalogue.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalogue.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Catalogue.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalogue.change_product(product)
    end
  end

  describe "stores" do
    alias Derp.Catalogue.Store

    import Derp.CatalogueFixtures

    @invalid_attrs %{id: nil, name: nil}

    test "list_stores/0 returns all stores" do
      store = store_fixture()
      assert Catalogue.list_stores() == [store]
    end

    test "get_store!/1 returns the store with given id" do
      store = store_fixture()
      assert Catalogue.get_store!(store.id) == store
    end

    test "create_store/1 with valid data creates a store" do
      valid_attrs = %{id: 42, name: "some name"}

      assert {:ok, %Store{} = store} = Catalogue.create_store(valid_attrs)
      assert store.id == 42
      assert store.name == "some name"
    end

    test "create_store/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalogue.create_store(@invalid_attrs)
    end

    test "update_store/2 with valid data updates the store" do
      store = store_fixture()
      update_attrs = %{id: 43, name: "some updated name"}

      assert {:ok, %Store{} = store} = Catalogue.update_store(store, update_attrs)
      assert store.id == 43
      assert store.name == "some updated name"
    end

    test "update_store/2 with invalid data returns error changeset" do
      store = store_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalogue.update_store(store, @invalid_attrs)
      assert store == Catalogue.get_store!(store.id)
    end

    test "delete_store/1 deletes the store" do
      store = store_fixture()
      assert {:ok, %Store{}} = Catalogue.delete_store(store)
      assert_raise Ecto.NoResultsError, fn -> Catalogue.get_store!(store.id) end
    end

    test "change_store/1 returns a store changeset" do
      store = store_fixture()
      assert %Ecto.Changeset{} = Catalogue.change_store(store)
    end
  end
end
