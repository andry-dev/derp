defmodule DerpWeb.ReviewRequestControllerTest do
  use DerpWeb.ConnCase

  import Derp.OracleFixtures

  alias Derp.Oracle.ReviewRequest

  @create_attrs %{
    address: 42,
    last_request: ~U[2023-01-22 15:03:00Z]
  }
  @update_attrs %{
    address: 43,
    last_request: ~U[2023-01-23 15:03:00Z]
  }
  @invalid_attrs %{address: nil, last_request: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all review_requests", %{conn: conn} do
      conn = get(conn, Routes.review_request_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create review_request" do
    test "renders review_request when data is valid", %{conn: conn} do
      conn = post(conn, Routes.review_request_path(conn, :create), review_request: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.review_request_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "address" => 42,
               "last_request" => "2023-01-22T15:03:00Z"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.review_request_path(conn, :create), review_request: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update review_request" do
    setup [:create_review_request]

    test "renders review_request when data is valid", %{conn: conn, review_request: %ReviewRequest{id: id} = review_request} do
      conn = put(conn, Routes.review_request_path(conn, :update, review_request), review_request: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.review_request_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "address" => 43,
               "last_request" => "2023-01-23T15:03:00Z"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, review_request: review_request} do
      conn = put(conn, Routes.review_request_path(conn, :update, review_request), review_request: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete review_request" do
    setup [:create_review_request]

    test "deletes chosen review_request", %{conn: conn, review_request: review_request} do
      conn = delete(conn, Routes.review_request_path(conn, :delete, review_request))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.review_request_path(conn, :show, review_request))
      end
    end
  end

  defp create_review_request(_) do
    review_request = review_request_fixture()
    %{review_request: review_request}
  end
end
