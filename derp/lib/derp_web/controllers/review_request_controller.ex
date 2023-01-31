defmodule DerpWeb.ReviewRequestController do
  use DerpWeb, :controller

  alias Derp.Oracle
  alias Derp.Oracle.ReviewRequest

  action_fallback DerpWeb.FallbackController

  def index(conn, _params) do
    review_requests = Oracle.list_review_requests()
    render(conn, "index.json", review_requests: review_requests)
  end

  def create(conn, params) do
    IO.inspect(params)
    case Oracle.create_review_request(params) do
      {:ok, true} ->
        conn
        |> put_status(:created)
        # |> put_resp_header("location", Routes.review_request_path(conn, :show, review_request))
        |> render("show.json", review_request: true)
      {:ok, false} ->
        conn
        |> put_status(:not_acceptable)
        |> render("show.json", review_request: false)
      {:error, :review_token_already_requested} ->
        conn
        |> put_status(:payment_required)
        |> render("error.json", review_request: false)
      {:error, reason} ->
        conn
        |> put_status(:not_acceptable)
        |> render("error.json", reason: reason)
    end
  end

  def show(conn, %{"id" => id}) do
    review_request = Oracle.get_review_request!(id)
    render(conn, "show.json", review_request: review_request)
  end

  def update(conn, %{"id" => id, "review_request" => review_request_params}) do
    review_request = Oracle.get_review_request!(id)

    with {:ok, %ReviewRequest{} = review_request} <- Oracle.update_review_request(review_request, review_request_params) do
      render(conn, "show.json", review_request: review_request)
    end
  end

  def delete(conn, %{"id" => id}) do
    review_request = Oracle.get_review_request!(id)

    with {:ok, %ReviewRequest{}} <- Oracle.delete_review_request(review_request) do
      send_resp(conn, :no_content, "")
    end
  end
end
