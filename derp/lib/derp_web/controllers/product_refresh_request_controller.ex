defmodule DerpWeb.ProductRefreshRequestController do
  use DerpWeb, :controller

  alias Derp.Oracle
  alias Derp.Oracle.ProductRefreshRequest

  action_fallback DerpWeb.FallbackController

  def index(conn, _params) do
    product_refresh_requests = Oracle.list_product_refresh_requests()
    render(conn, "index.json", product_refresh_requests: product_refresh_requests)
  end

  def create(conn, %{"product_refresh_request" => product_refresh_request_params}) do
    with {:ok, %ProductRefreshRequest{} = product_refresh_request} <- Oracle.create_product_refresh_request(product_refresh_request_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.product_refresh_request_path(conn, :show, product_refresh_request))
      |> render("show.json", product_refresh_request: product_refresh_request)
    end
  end

  def show(conn, %{"id" => id}) do
    product_refresh_request = Oracle.get_product_refresh_request!(id)
    render(conn, "show.json", product_refresh_request: product_refresh_request)
  end

  def update(conn, %{"id" => id, "product_refresh_request" => product_refresh_request_params}) do
    product_refresh_request = Oracle.get_product_refresh_request!(id)

    with {:ok, %ProductRefreshRequest{} = product_refresh_request} <- Oracle.update_product_refresh_request(product_refresh_request, product_refresh_request_params) do
      render(conn, "show.json", product_refresh_request: product_refresh_request)
    end
  end

  def delete(conn, %{"id" => id}) do
    product_refresh_request = Oracle.get_product_refresh_request!(id)

    with {:ok, %ProductRefreshRequest{}} <- Oracle.delete_product_refresh_request(product_refresh_request) do
      send_resp(conn, :no_content, "")
    end
  end
end
