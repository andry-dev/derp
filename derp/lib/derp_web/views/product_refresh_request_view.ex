defmodule DerpWeb.ProductRefreshRequestView do
  use DerpWeb, :view
  alias DerpWeb.ProductRefreshRequestView

  def render("index.json", %{product_refresh_requests: product_refresh_requests}) do
    %{data: render_many(product_refresh_requests, ProductRefreshRequestView, "product_refresh_request.json")}
  end

  def render("show.json", %{product_refresh_request: product_refresh_request}) do
    %{data: render_one(product_refresh_request, ProductRefreshRequestView, "product_refresh_request.json")}
  end

  def render("product_refresh_request.json", %{product_refresh_request: product_refresh_request}) do
    %{
      id: product_refresh_request.id,
      address: product_refresh_request.address
    }
  end
end
