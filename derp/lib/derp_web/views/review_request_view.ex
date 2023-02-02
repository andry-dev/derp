defmodule DerpWeb.ReviewRequestView do
  use DerpWeb, :view
  alias DerpWeb.ReviewRequestView

  def render("index.json", %{review_requests: review_requests}) do
    %{data: render_many(review_requests, ReviewRequestView, "review_request.json")}
  end

  def render("show.json", %{review_request: result}) do
    %{data: %{result: result}}
  end

  def render("error.json", %{reason: :review_token_already_requested}) do
    %{data: %{result: false, code: 0, reason: "Reviewer already spent the daily free review token request"}}
  end

  def render("error.json", %{reason: :no_new_products}) do
    %{data: %{result: false, code: 1, reason: "No new products!"}}
  end

  def render("error.json", %{reason: reason}) do
    %{data: %{result: false, code: 2, reason: reason}}
  end

  def render("review_request.json", %{review_request: review_request}) do
    %{
      id: review_request.id,
      address: review_request.address,
      products: review_request.products
    }
  end
end
