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
end
