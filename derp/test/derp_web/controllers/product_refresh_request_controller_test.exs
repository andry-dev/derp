defmodule DerpWeb.ProductRefreshRequestControllerTest do
  use DerpWeb.ConnCase

  import Derp.OracleFixtures

  alias Derp.Oracle.ProductRefreshRequest

  @create_attrs %{
    address: "some address"
  }
  @update_attrs %{
    address: "some updated address"
  }
  @invalid_attrs %{address: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all product_refresh_requests", %{conn: conn} do
      conn = get(conn, Routes.product_refresh_request_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product_refresh_request" do
    test "renders product_refresh_request when data is valid", %{conn: conn} do
      conn = post(conn, Routes.product_refresh_request_path(conn, :create), product_refresh_request: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.product_refresh_request_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "address" => "some address"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.product_refresh_request_path(conn, :create), product_refresh_request: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product_refresh_request" do
    setup [:create_product_refresh_request]

    test "renders product_refresh_request when data is valid", %{conn: conn, product_refresh_request: %ProductRefreshRequest{id: id} = product_refresh_request} do
      conn = put(conn, Routes.product_refresh_request_path(conn, :update, product_refresh_request), product_refresh_request: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.product_refresh_request_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "address" => "some updated address"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product_refresh_request: product_refresh_request} do
      conn = put(conn, Routes.product_refresh_request_path(conn, :update, product_refresh_request), product_refresh_request: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product_refresh_request" do
    setup [:create_product_refresh_request]

    test "deletes chosen product_refresh_request", %{conn: conn, product_refresh_request: product_refresh_request} do
      conn = delete(conn, Routes.product_refresh_request_path(conn, :delete, product_refresh_request))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.product_refresh_request_path(conn, :show, product_refresh_request))
      end
    end
  end

  defp create_product_refresh_request(_) do
    product_refresh_request = product_refresh_request_fixture()
    %{product_refresh_request: product_refresh_request}
  end
end
