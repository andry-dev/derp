defmodule Derp.OracleTest do
  use Derp.DataCase

  alias Derp.Oracle

  describe "review_requests" do
    alias Derp.Oracle.ReviewRequest

    import Derp.OracleFixtures

    @invalid_attrs %{address: nil, last_request: nil}

    test "list_review_requests/0 returns all review_requests" do
      review_request = review_request_fixture()
      assert Oracle.list_review_requests() == [review_request]
    end

    test "get_review_request!/1 returns the review_request with given id" do
      review_request = review_request_fixture()
      assert Oracle.get_review_request!(review_request.id) == review_request
    end

    test "create_review_request/1 with valid data creates a review_request" do
      valid_attrs = %{address: 42, last_request: ~U[2023-01-22 15:03:00Z]}

      assert {:ok, %ReviewRequest{} = review_request} = Oracle.create_review_request(valid_attrs)
      assert review_request.address == 42
      assert review_request.last_request == ~U[2023-01-22 15:03:00Z]
    end

    test "create_review_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Oracle.create_review_request(@invalid_attrs)
    end

    test "update_review_request/2 with valid data updates the review_request" do
      review_request = review_request_fixture()
      update_attrs = %{address: 43, last_request: ~U[2023-01-23 15:03:00Z]}

      assert {:ok, %ReviewRequest{} = review_request} = Oracle.update_review_request(review_request, update_attrs)
      assert review_request.address == 43
      assert review_request.last_request == ~U[2023-01-23 15:03:00Z]
    end

    test "update_review_request/2 with invalid data returns error changeset" do
      review_request = review_request_fixture()
      assert {:error, %Ecto.Changeset{}} = Oracle.update_review_request(review_request, @invalid_attrs)
      assert review_request == Oracle.get_review_request!(review_request.id)
    end

    test "delete_review_request/1 deletes the review_request" do
      review_request = review_request_fixture()
      assert {:ok, %ReviewRequest{}} = Oracle.delete_review_request(review_request)
      assert_raise Ecto.NoResultsError, fn -> Oracle.get_review_request!(review_request.id) end
    end

    test "change_review_request/1 returns a review_request changeset" do
      review_request = review_request_fixture()
      assert %Ecto.Changeset{} = Oracle.change_review_request(review_request)
    end
  end

  describe "product_refresh_requests" do
    alias Derp.Oracle.ProductRefreshRequest

    import Derp.OracleFixtures

    @invalid_attrs %{address: nil}

    test "list_product_refresh_requests/0 returns all product_refresh_requests" do
      product_refresh_request = product_refresh_request_fixture()
      assert Oracle.list_product_refresh_requests() == [product_refresh_request]
    end

    test "get_product_refresh_request!/1 returns the product_refresh_request with given id" do
      product_refresh_request = product_refresh_request_fixture()
      assert Oracle.get_product_refresh_request!(product_refresh_request.id) == product_refresh_request
    end

    test "create_product_refresh_request/1 with valid data creates a product_refresh_request" do
      valid_attrs = %{address: "some address"}

      assert {:ok, %ProductRefreshRequest{} = product_refresh_request} = Oracle.create_product_refresh_request(valid_attrs)
      assert product_refresh_request.address == "some address"
    end

    test "create_product_refresh_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Oracle.create_product_refresh_request(@invalid_attrs)
    end

    test "update_product_refresh_request/2 with valid data updates the product_refresh_request" do
      product_refresh_request = product_refresh_request_fixture()
      update_attrs = %{address: "some updated address"}

      assert {:ok, %ProductRefreshRequest{} = product_refresh_request} = Oracle.update_product_refresh_request(product_refresh_request, update_attrs)
      assert product_refresh_request.address == "some updated address"
    end

    test "update_product_refresh_request/2 with invalid data returns error changeset" do
      product_refresh_request = product_refresh_request_fixture()
      assert {:error, %Ecto.Changeset{}} = Oracle.update_product_refresh_request(product_refresh_request, @invalid_attrs)
      assert product_refresh_request == Oracle.get_product_refresh_request!(product_refresh_request.id)
    end

    test "delete_product_refresh_request/1 deletes the product_refresh_request" do
      product_refresh_request = product_refresh_request_fixture()
      assert {:ok, %ProductRefreshRequest{}} = Oracle.delete_product_refresh_request(product_refresh_request)
      assert_raise Ecto.NoResultsError, fn -> Oracle.get_product_refresh_request!(product_refresh_request.id) end
    end

    test "change_product_refresh_request/1 returns a product_refresh_request changeset" do
      product_refresh_request = product_refresh_request_fixture()
      assert %Ecto.Changeset{} = Oracle.change_product_refresh_request(product_refresh_request)
    end
  end
end
